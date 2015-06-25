# Code based on s3_cors_fileupload
# https://github.com/batter/s3_cors_fileupload

class FilestreamsController < ApplicationController
  before_action :get_deposit
  prepend_view_path "app/views/deposits"

  # GET /filestreams
  # GET /filestreams.json
  def index
    @filestreams = @deposit.filestreams #File.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @filestreams.map(&:to_jq_upload) }
    end
  end

  # POST /filestreams
  # POST /filestreams.json
  def create
    parameters = params.require(:filestream).permit(:url, :bucket, :key)
    @filestream = Filestream.new(parameters)
    @filestream.attributes = { deposit: @deposit }
    respond_to do |format|
      if @filestream.save
        format.html {
          render :json => @filestream.to_jq_upload,
          :content_type => 'text/html',
          :layout => false
        }
        format.json { render json: @filestream.to_jq_upload, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @filestream.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /filestreams/1
  # DELETE /filestreams/1.json
  def destroy
    @filestream = Filestream.find(params[:id])
    @filestream.destroy

    respond_to do |format|
      format.html { redirect_to filestreams_url }
      format.json { head :no_content }
      format.xml { head :no_content }
    end
  end

  # used for s3_uploader
  def generate_key
    render json: {
      key: "#{folder_name}/#{params[:filename]}",
      success_action_redirect: "/"
    }
  end

  private

  def get_deposit
    @deposit = Deposit.find(params[:deposit_id])
  end
  
  def folder_name
    return ENV['institution'] + "/upload/#{@deposit.import_profile}/#{@deposit.folder_name}"
  end 
end
