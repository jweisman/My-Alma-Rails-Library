module Alma
	require 'rest-client'
	require 'json'
	
# Alma API methods

	def alma_api_get(uri)
		response =
		 RestClient.get ENV['almaurl'] + uri,
				accept: :json, 
				authorization: 'apikey ' + ENV['apikey']
		return JSON.parse(response.body)
	end
	
	def alma_api_put(uri, data)
		response =
		 RestClient.put ENV['almaurl'] + uri,
		 	data.to_json,
			accept: :json, 
			authorization: 'apikey ' + ENV['apikey'],
			content_type: :json
		return JSON.parse(response.body)		
	end
	
	def alma_api_post(uri, data)
		response =
		 RestClient.post ENV['almaurl'] + uri,
		 	data.to_json,
			accept: :json, 
			authorization: 'apikey ' + ENV['apikey'],
			content_type: :json
		return JSON.parse(response.body)	
	end	
	
	def alma_api_delete(uri)
		RestClient.delete ENV['almaurl'] + uri,
			authorization: 'apikey ' + ENV['apikey']
	end	
  	
end
