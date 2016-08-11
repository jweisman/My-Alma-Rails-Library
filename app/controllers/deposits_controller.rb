include SwordHelper
include Utilities
include AwsHelper

class DepositsController < ApplicationController
	before_action :require_valid_user
  before_action :on_behalf_of
  before_action :deposit_profiles, on: [:new, :create, :edit]

  def index
    alma_get_deposits
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
      :id => deposit.entry.id,
      :dc => dc, 
      :files => deposit.entry.sword_derived_resource_links,
      :view_url => deposit.entry.alternate_uri || '#',
      :updated => deposit.entry.updated,
      :title => deposit.entry.title,
      :status => deposit.entry.sword_treatment,
      :note => deposit.entry.summary
    }
  end

  def update
    verb = 'updated'
    if params[:button] == 'submit'
      sword_update_md params[:id], [], false
      verb = 'submitted'
    elsif params[:files]
      begin 
        temp_file = Rails.root.join('tmp',"deposit-#{session.id}.zip")
        zip_files temp_file, params[:files]
        sword_add_zip params[:id], temp_file
      ensure
        File.delete temp_file
      end
    else
      sword_update_md params[:id], params[:dc]
    end
    redirect_to deposits_path, 
      notice: %Q[Your 
          #{view_context.link_to("deposit", edit_deposit_path(params[:id]))} 
          was successfully #{verb}. 
         ]
  end

  def create
    begin 
      temp_file = Rails.root.join('tmp',"deposit-#{session.id}.zip")
      zip_files temp_file, params[:files]
      receipt = sword_zip_deposit(
        @deposit_profiles[params[:collection]]["url"], 
        params[:dc], 
        (params[:button]=='draft'),
        temp_file
        )
    ensure
      File.delete temp_file
    end
    redirect_to deposits_path, 
      notice: %Q[Your 
        #{view_context.link_to("deposit", edit_deposit_path(receipt.entry.id))} 
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
    sword_delete_deposit params[:id]
	 	redirect_to deposits_path, notice: "Your deposit was successfully withdrawn."
  end

  private
  
  def on_behalf_of
    @obo = current_user.id
  end

  def deposit_profiles
    if !session[:deposit_profiles]
      collections = sword_sd
      session[:deposit_profiles] = Hash[collections.map{ 
        |col| [col.href.split('/')[-1], { 
          "title" => col.title.to_s, 
          "url" => col.href,
          "collectionPolicy" => col.sword_collection_policy 
          }]
        }]
    end   
    @deposit_profiles = session[:deposit_profiles]
  end

  def alma_get_deposits
    @deposits = alma_api_get "/users/#{current_user.id}/deposits"
  end
end