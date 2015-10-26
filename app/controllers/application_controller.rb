class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  include Alma

  helper_method :current_user, :admin_user?

  def current_user
    @current_user ||= User.new(JSON.parse(session[:user], symbolize_names: true)) if session[:user_id]
  end

  def admin_user?
    current_user && current_user.name == "Josh Weisman"
  end
  
  def require_valid_user
  	if session[:user_id] == nil
  		render :login and return
  	end
  end
  
end
