class DepositsController < ApplicationController
	before_action :require_valid_user
	before_action :get_deposit, except: [:index, :create, :new]

  include S3helper

  def index
  	@deposits = Deposit.where("user_id=? and status != 'DELETED'", current_user)
  	#@deposits = Deposit.where("id < 6").destroy_all
  	#render plain: "done"
  end

  def new
  	@deposit = Deposit.new()
  end

  def edit

  end

  def update
  	@deposit.metadata = params["metadata"]
  	@deposit.save
  	redirect_to deposit_source_files_path(@deposit)
  end

  def create

  	@deposit = Deposit.new()
  	@deposit.attributes = { metadata: params["metadata"],
  							user: current_user,
  							status: "CREATED",
  							folder_name: SecureRandom.uuid.gsub(/-/,''),
  							bucket: ENV['amazonbucket']}
  	@deposit.save
  	write_file "#{folder_name}/.lock", "test"
  	redirect_to deposit_source_files_path(@deposit)
  end

  def destroy
  	@deposit.status = "DELETED"
  	@deposit.save
	head :no_content 
  end

  def confirm

  end

  def submit
  	save_metadata_file
  	delete_file "#{folder_name}/.lock"
  	@deposit.status = "SUBMITTED"
  	@deposit.save
  	redirect_to deposits_path, notice: "Your deposit was successfully submitted."
  end

  private

  def get_deposit
  	@deposit = Deposit.find(params[:id] || params[:deposit_id])
  end

  def save_metadata_file
  	content = %Q(<?xml version="1.0" encoding="UTF-8"?>
	<metadata
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:dc="http://purl.org/dc/elements/1.1/">
		)
	@deposit.metadata.each do |md|
		content << "<" + md[0] + ">" + md[1] + "</" + md[0] + ">"
	end
	content << "</metadata>"

  	write_file "#{folder_name}/metadata.dc.xml",
  		content
  end

  def folder_name
  	return "01TEST/upload/#{@deposit.folder_name}"
  end
end