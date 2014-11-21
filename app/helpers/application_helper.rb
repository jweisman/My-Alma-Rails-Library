module ApplicationHelper
	require 'net/http'
	require 'json'

	def alma_api_get(uri)
		uri = URI.parse(ENV['almaurl'] + uri)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Get.new(uri.request_uri)
		request.initialize_http_header({"Accept" => "application/json", 
			"Authorization" => "apikey " + ENV['apikey']})

		response = http.request(request)
		return JSON.parse(response.body)
	end
	
	def alma_api_put(uri, data)
		uri = URI.parse(ENV['almaurl'] + uri)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Put.new(uri.request_uri)
		request.initialize_http_header({"Content-Type" => "application/json", 
			"Authorization" => "apikey " + ENV['apikey'],
			"Content-Length" => data.length.to_s,
			"Accept" => "application/json"})
			
		request.body = data.to_json

		response = http.request(request)
		return JSON.parse(response.body)		
	end
	
	def alma_api_delete(uri)
		uri = URI.parse(ENV['almaurl'] + uri)
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		request = Net::HTTP::Delete.new(uri.request_uri)
		request.initialize_http_header({"Authorization" => "apikey " + ENV['apikey']})

		response = http.request(request)
	end	
	

end
