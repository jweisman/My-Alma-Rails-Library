include SwordHelper
include Utilities
include AwsHelper

class DepositsController < ApplicationController
	before_action :require_valid_user
  before_action :on_behalf_of
  before_action :deposit_profiles, on: [:new, :create, :edit]

  def index
    #@deposits = alma_get_deposits
    @deposits = {}
  end

  def new
    @deposit = {
      :dc => dc_fields,
      :files => []
    }
  end

  def edit
    deposit = sword_get_deposit(params[:id])
    # select relevant DC fields
    dc = deposit.entry.dublin_core_extensions.select { |a| 
      dc_fields.any? { |i| i.name == a.name }
    }

    @deposit = {
      :dc => dc, 
      :files => deposit.entry.sword_derived_resource_links,
      :view_url => deposit.entry.alternate_uri || '#'
    }
  end

  def update
    if params[:files]
      begin 
        temp_file = Rails.root.join('tmp',"deposit-#{session.id}.zip")
        zip_files temp_file, params[:files]
        sword_add_zip params[:id], temp_file
      ensure
        File.delete temp_file
      end
      redirect_to deposits_path, 
        notice: "Your deposit was successfully updated."
    else
      sword_update_md params[:id], params[:dc]
      redirect_to deposits_path, 
        notice: "Your deposit was successfully updated."
    end
  end

  def create
    begin 
      temp_file = Rails.root.join('tmp',"deposit-#{session.id}.zip")
      zip_files temp_file, params[:files]
      receipt = sword_zip_deposit(
        @deposit_profiles[params[:collection]][:url], 
        params[:dc], 
        temp_file
        )
    ensure
      File.delete temp_file
    end
    redirect_to deposits_path, 
      notice: %Q[Your 
        #{view_context.link_to("deposit", edit_deposit_path(receipt.entry.sword_verbose_description))} 
        was successfully completed. 
       ]
  end

  def delete_file
    deposit = sword_get_deposit(params[:deposit_id])
    file = base64_decode(params[:id])
    # validate file URI
    if deposit.entry.sword_derived_resource_links.any? { |l| l.href == file }
      sword_delete_file file
      head :no_content
    else
      render :nothing => true, :status => 400
    end
  end

  def destroy
    ## TODO
    @deposit.delete_filestreams
    session[:deposit] = nil
	 	redirect_to deposit_path, notice: "Your deposit was successfully deleted."
  end

  private
  
  def on_behalf_of
    @obo = current_user.id
  end

  def deposit_profiles
    #Rails.cache.delete("deposit_profiles")
    @deposit_profiles =
    Rails.cache.fetch("deposit_profiles", expires_in: 6.hours) do
      collections = sword_sd
      Hash[collections.map{ 
        |col| [col.href.split('/')[-1], { :title=> col.title.to_s, :url=> col.href }]
        }] 
    end    
  end

  ##### TEMP
  def alma_get_deposits
    response = 
    RestClient.get "https://#{ENV['alma']}.alma.exlibrisgroup.com/view/sru/#{ENV['institution']}?version=1.2&operation=searchRetrieve&recordSchema=marcxml&query=alma.other_system_number=SWORD"

    xml = Nokogiri::XML(response)
    deposits = []
    deposit_nodes = xml.xpath('/xmlns:searchRetrieveResponse/xmlns:records/xmlns:record/xmlns:recordData/record')
    deposit_nodes.each do |deposit_node|
      mms_id = deposit_node.at_xpath('controlfield[@tag="001"]').text
      title = deposit_node.at_xpath('datafield[@tag="245"]/subfield[@code="a"]').text
      author = deposit_node.at_xpath('datafield[@tag="100"]/subfield[@code="a"]').text
      view = deposit_node.at_xpath('datafield[@tag="035"]/subfield[@code="a"]').text
      view = "/deposits/#{view[view.index('(SWORD)') + 7..-1]}/view"
      created_date = deposit_node.at_xpath('datafield[@tag="260"]/subfield[@code="c"]').text

      deposits << 
        { :id => mms_id, :title => title, :author => author, :view => view,
        :created_date => created_date  }
    end

    return deposits
  end
end