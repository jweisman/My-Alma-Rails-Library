# Code based on s3_cors_fileupload
# https://github.com/batter/s3_cors_fileupload

class FilestreamsController < ApplicationController
  before_action :get_deposit
  prepend_view_path "app/views/deposits"

  include S3Helper
  require "base64"

  # GET /filestreams
  # GET /filestreams.json
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @deposit.filestreams.map(&:to_jq_upload) }
    end
  end

  # POST /filestreams
  # POST /filestreams.json
  def create
    parameters = params.require(:filestream).permit(:url, :key)
    @filestream = Filestream.new(parameters)
    
    respond_to do |format|
      format.html {
        render :json => @filestream.to_jq_upload,
        :content_type => 'text/html',
        :layout => false
      }
      format.json { render json: @filestream.to_jq_upload, status: :created }
    end
  end

  # DELETE /filestreams/1
  # DELETE /filestreams/1.json
  def destroy
    delete_file "#{@deposit.folder}/#{Base64.decode64(params[:id])}"

    respond_to do |format|
      format.html { redirect_to filestreams_url }
      format.json { head :no_content }
      format.xml { head :no_content }
    end
  end

  # used for s3_uploader
  def generate_key
    render json: {
      key: "#{@deposit.folder}/#{params[:filename]}",
      success_action_redirect: "/"
    }
  end

  private

  def get_deposit
    @deposit = Deposit.new(
      JSON.parse(session[:deposit], symbolize_names: true)) if session[:deposit]
  end
end
