class CardController < ApplicationController
include ApplicationHelper

  def index
  	if current_user.blank?
  		return redirect_to root_path
  	end
	@user = get_user()
  	@message = params[:message]
  	render
  end
  
  def update
  	user = get_user()
  	user["first_name"] = params[:user]["first_name"]
  	user["last_name"]  = params[:user]["last_name"]
 	newuser = alma_api_put("/users/#{current_user.email}", user)
  	redirect_to :action => "index", :message => "Your information was updated."
  end
  
  private
  
  def get_user
  	user = alma_api_get("/users/#{current_user.email}")
  	return JSON.parse(user)
  end
  
end

# with better error handling, but harder to read
#  def update
#  	user = GetUser()
#  	user["first_name"] = params[:user]["first_name"]
#  	user["last_name"]  = params[:user]["last_name"]
#  	begin
#		newuser = AlmaApiPut("/users/" + current_user.email, user)
#	rescue Exception => e
#		@message = "There was an error updating your library card (" +
#			e.message + ")"
#		render :error
#		return
#	end
# 	redirect_to :action => "index", :message => "Your information was updated."
#  end
