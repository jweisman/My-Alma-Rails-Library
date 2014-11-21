class RequestsController < ApplicationController
	before_filter :require_valid_user

  def index
  	@requests = get_requests()
  	@message = params[:message]
  	render
  end
  
  def cancel
  	alma_api_delete("/users/#{current_user.uid}/requests/#{params["requestId"]}")
  	redirect_to :action => "index", :message => "Your request was successfully cancelled."
  end
  
  private
  
  def get_requests
  	requests = alma_api_get("/users/#{current_user.uid}/requests")
  	return requests
  end

end
