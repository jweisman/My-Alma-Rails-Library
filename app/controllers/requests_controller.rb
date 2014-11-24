class RequestsController < ApplicationController
	before_action :require_valid_user
	before_action :get_requests

  def index

  end
  
  def cancel
  	alma_api_delete("/users/#{current_user.uid}/requests/#{params["requestId"]}")
  	redirect_to requests_path, notice: "Your request was successfully cancelled."
  end
  
  private
  
  def get_requests
  	@requests = alma_api_get("/users/#{current_user.uid}/requests")
  end

end
