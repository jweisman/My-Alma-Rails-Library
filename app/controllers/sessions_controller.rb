class SessionsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: :create

  def create
    user = User.from_omniauth(env["omniauth.auth"])

    # Confirm user exists in Alma
    if valid_alma_user?(user.id)
      session[:user] = user.to_json
      session[:user_id] = user.id
      redirect_to CGI.unescape(params[:redirect] || root_path)
    else
      flash.now[:alert] = "Your user doesn't exist in Alma. (#{user.id})"
      render :error    
    end    
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
  
  def login
    render :login
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
