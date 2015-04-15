class CardController < ApplicationController
	before_action :require_valid_user
	before_action :get_user
  
  def update
  	@user["first_name"] = params[:user]["first_name"]
  	@user["last_name"]  = params[:user]["last_name"]
 	  newuser = alma_api_put("/users/#{current_user.uid}", @user)

  	redirect_to card_path, notice: "Your information was updated."
  end
  
  private
  
  def get_user
  	@user = alma_api_get("/users/#{current_user.uid}")
  end
  
end

# with better error handling, but harder to read
#  def update
#  	@user["first_name"] = params[:user]["first_name"]
#  	@user["last_name"]  = params[:user]["last_name"]
#  	begin
#		newuser = AlmaApiPut("/users/#{current_user.uid}, @user)
#	rescue Exception => e
#		flash.now["notice"] = "There was an error updating your library card (" +
#			e.message + ")"
#		render :error and return
#	end
# 	redirect_to card_path, notice: "Your information was updated."
#  end
