module Paypal
	require 'rest-client'
	require 'json'
	require 'xmlsimple'

	def send_payment(token, payment)
		response =
		 RestClient.post ENV['paypalurl'] + "/payments/payment",
		 	payment.to_json,
			accept: :json, 
			authorization: 'Bearer ' + token,
			content_type: :json
		return JSON.parse(response.body)
	end

	def execute_payment(token, payment_id, payer_id)
		response =
		 RestClient.post ENV['paypalurl'] + 
		 	"/payments/payment/#{payment_id}/execute",
		 	"{ \"payer_id\" : \"#{payer_id}\" }",
			accept: :json, 
			authorization: 'Bearer ' + token,
			content_type: :json
		return JSON.parse(response.body)
	end

	def get_token
		resource = RestClient::Resource.new(
			ENV['paypalurl'] + "/oauth2/token",
			ENV['paypayclientid'],
			ENV['paypalsecret']
			)
		response = resource.post( 
		 	{ grant_type: 'client_credentials' },
			accept: :json, 
			"Accept-Language" => "en_US"
			)
		return JSON.parse(response.body)["access_token"]
	end
	
	def get_pds_bor_info(handle)
		response =
		 RestClient.get ENV['pdsurl'] + "/pds?func=bor-info&pds_handle=#{handle}"
		return XmlSimple.xml_in(response.body)
	end		
	
	# Classes to create payment JSON for Paypal
	class Payment

		def initialize(amount, currency, base_url)
			@intent = "sale"
			@redirect_urls = RedirectUrls.new(base_url + 
				Rails.application.routes.url_helpers.confirm_fines_path,
				base_url + Rails.application.routes.url_helpers.fines_path)
			@payer = Payer.new("paypal")
			@transactions = [Transaction.new(
				amount, currency,"Fine payment from My Alma Library")
				]
		end
		
	end

	private
	class RedirectUrls
		def initialize(return_url, cancel_url)
			@return_url = return_url
			@cancel_url = cancel_url
		end	
	end
	
	class Payer
		def initialize(payment_method)
			@payment_method = payment_method
		end
	end
	
	class Transaction
		def initialize(total, currency, description)
			@amount = Amount.new(total, currency)
			@description = description
		end
	end
	
	class Amount
		def initialize(total, currency)
			@total = sprintf("%.2f",total)
			@currency = currency
		end
	end
end