class DepositsController < ApplicationController
	before_action :require_valid_user
	before_action :get_deposit
  before_action :import_profiles, on: [:index, :new, :edit]

  def show
    if @deposit.import_profile == nil
      i = @import_profiles.select{|i| i["digital_details"]["collection_assignment"]["value"] == params["collection"]}
      @deposit.import_profile = i.first["id"].to_i if !i.empty?
    end

    respond_to do |format|
      format.html 
      format.json { render json: @deposit.to_json }
    end

  end

  def create
    @deposit.attributes = params[:deposit].permit(:import_profile, md_params)
    session[:deposit] = @deposit.to_json
    if @deposit.valid?
      @deposit.lock
      redirect_to deposit_filestreams_path
    else
      render :show
    end
  end

  def destroy
    @deposit.delete_filestreams
    session[:deposit] = nil
	 	redirect_to deposit_path, notice: "Your deposit was successfully deleted."
  end

  def submit
  	@deposit.save_metadata_file
    @deposit.unlock
    session[:deposit] = nil 
  	redirect_to deposit_path, notice: "Your deposit was successfully submitted."
  end

  private
  
  def md_params
    {:metadata => [:title, :author, :description]}
  end

  def get_deposit
    @deposit ||= Deposit.new
    @deposit.attributes = JSON.parse(session[:deposit], symbolize_names: true) if session[:deposit]
  end
  
  def import_profiles
    #Rails.cache.delete("import_profiles")
    @import_profiles =
    Rails.cache.fetch("import_profiles", expires_in: 5) do
      alma_api_get("/conf/md-import-profiles?ie_type=DIGITAL&type=REPOSITORY")["import_profile"]
    end    
  end
end