class DepositsController < ApplicationController
	before_action :require_valid_user
	before_action :get_deposit, except: [:index, :create, :new]
  before_action :import_profiles, on: [:index, :new, :edit]

  include S3Helper

  def index
  	@deposits = Deposit.where("user_id=? and status != 'DELETED'", current_user)
  end

  def new
  	@deposit = Deposit.new()
    i = @import_profiles.select{|i| i["digital_details"]["collection_assignment"]["value"] == params["collection"]}
    @deposit.import_profile = i.first["id"].to_i if i
  end

  def update
  	@deposit.update!(params[:deposit].permit(md_params))
  	redirect_to deposit_filestreams_path(@deposit)
  end

  def create
  	@deposit = Deposit.new(params[:deposit].permit(:import_profile, md_params))
    @deposit.user = current_user
  	@deposit.save
  	write_file "#{folder_name}/.lock", nil
  	redirect_to deposit_filestreams_path(@deposit)
  end

  def destroy
    @deposit.destroy
	 	head :no_content 
  end

  def submit
  	save_metadata_file
  	delete_file "#{folder_name}/.lock"
  	@deposit.status = "SUBMITTED"
  	@deposit.save
  	redirect_to deposits_path, notice: "Your deposit was successfully submitted."
  end

  private
  
  def md_params
    {:metadata => [:title, :description]}
  end

  def get_deposit
  	@deposit = Deposit.find(params[:id] || params[:deposit_id])
  end

  def save_metadata_file
    content = 
      %Q(
        <collection>
           <record>
              <leader>     aas          a     </leader>
              <controlfield tag="008">       #{Time.now.strftime("%Y")}</controlfield>
              <datafield tag="100" ind1="1" ind2=" ">
                <subfield code="a">#{@deposit.metadata["author"]}</subfield>
              </datafield>
              <datafield tag="245" ind1="1" ind2="2">
                <subfield code="a">#{@deposit.metadata["title"]}</subfield>
              </datafield>
              <datafield tag="260" ind1=" " ind2=" ">
                <subfield code="c">#{Time.now.strftime("%B %d, %Y")}</subfield>
              </datafield>
           </record>
         </collection> 
      )
  	
  	write_file "#{folder_name}/marc.xml",	content
  end

  def folder_name
    ENV['institution'] + "/upload/#{@deposit.import_profile}/#{@deposit.folder_name}"
  end
  
  def import_profiles
    #Rails.cache.delete("import_profiles")
    @import_profiles =
    Rails.cache.fetch("import_profiles", expires_in: 5) do
      alma_api_get("/conf/md-import-profiles?ie_type=DIGITAL&type=REPOSITORY")["import_profile"]
    end    
  end
end