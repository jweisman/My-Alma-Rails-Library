class RequestsController < ApplicationController
include ApplicationHelper

  def index
  	if current_user.blank?
  		return redirect_to root_path
  	end
  	@requests = get_requests()
  	@message = params[:message]
  	render
  end
  
  def cancel
  	alma_api_delete("/users/#{current_user.email}/requests/#{params["requestId"]}")
  	redirect_to :action => "index", :message => "Your request was successfully cancelled."
  end
  
  private
  
  def get_requests
  	user = alma_api_get("/users/#{current_user.email}/requests")
  	return JSON.parse(user)
  end

end
