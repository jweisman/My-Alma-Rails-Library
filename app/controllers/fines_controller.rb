class FinesController < ApplicationController
	before_action :require_valid_user, except: [:validate]
	before_action :get_fines, only: [:index, :pay]
  layout :choose_layout
  
	include Paypal
  
  def pay
  	payment = Payment.new(@fines["total_sum"], @fines["currency"], request.base_url) 
  	token = get_token
  	
  	# store in session for later use
  	session[:token] = token

	  # send payment to PayPal
  	transaction = send_payment(token, payment)

  	# find approval URL to redirect to
  	if transaction["state"] == "created"
      approval_url = transaction['links'].find {
          |key, val| key['rel'] == "approval_url"
        } ['href'] 
        redirect_to approval_url
  	else
  		flash.now[:alert] = "There was an error processing your payment."
  		render :error and return
  	end
  end
  
  def confirm
  	# Execute payment at PayPal
  	payment = execute_payment(session[:token], params["paymentId"], params["PayerID"])

  	if payment["state"] == "approved"
  		amount = payment["transactions"][0]["amount"]["total"]

      # Post payment to Alma
  		p = {
  			"op"						=>	"pay",
  			"amount"					=> amount,
  			"method"					=> "ONLINE",
  			"external_transaction_id"	=> params["paymentId"]
  		}
  		qs = p.collect {|key,value| "#{key}=#{value}"}.join "&"
  		alma_api_post("/users/#{current_user.uid}/fees/all?#{qs}", nil)

  		redirect_to fines_path, 
  			notice: "Your payment has been successfully processed and #{amount} 
  				has been credited to your account. Thanks!"
  	else
		  flash.now[:alert] = "There was an error processing your payment."
		  render :error and return
  	end  	

  end
  
  def validate
  	#called from Primo to resolve users from PDS handle
  	if params["pds_handle"].blank?
  		return redirect_to root_path
  	end

  	bor_info = get_pds_bor_info(params["pds_handle"])
    if bor_info["error"]
      flash.now[:alert] = "There was a problem logging you in."
      render :error and return
    end

    user = User.from_pds(bor_info)
    session[:user_id] = user.id
    redirect_to fines_path	
  end  
  
  private

  def choose_layout
    "popup" if current_user and 
      current_user.provider.start_with?('PDS')
  end
  
  def get_fines
    @fines = alma_api_get("/users/#{current_user.uid}/fees")
	end
end
