class SessionsController < ApplicationController

  def create
    user = User.from_omniauth(env["omniauth.auth"])

    # Confirm user exists in Alma
    if valid_alma_user?(user.uid)
      session[:user_id] = user.id
      redirect_to root_path
    else
      flash.now[:alert] = "Your user doesn't exist in Alma. (#{user.uid})"
      render :error    
    end    
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
  
  private
  
  def valid_alma_user?(user_id)
    begin
  	   user = alma_api_get("/users/#{user_id}") 
       return true
    rescue RestClient::BadRequest => e
      if e.response.body.include? "401861" # user not found
        return false
      else
        raise e
      end
    end
  end
 
end
