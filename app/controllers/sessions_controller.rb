class SessionsController < ApplicationController

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    
    # Confirm user exists in Alma
    if valid_alma_user?(user.uid)
  		flash[:alert] = "Your user doesn't exist in Alma. (#{user.uid})"
  		render :error
    else
	    session[:user_id] = user.id
	    redirect_to root_path    
    end    
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
  
  private
  
  def valid_alma_user?(user_id)
  	user = alma_api_get("/users/#{user_id}") 	
  	return user["first_name"].nil?
  end
 
end
