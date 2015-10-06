module AwsHelper
require 'aws-sdk-core'
require 'rest-client'
require 'nokogiri'
include ERB::Util

	#############
	# CloudSearch
	#############

	def cs_search(q, start = 0)
		JSON.parse RestClient.get "#{cs_search_endpoint}?q=#{url_encode(q)}&size=10&start=#{start}"
	end	

	def cs_post(payload)
        aws_post('cloudsearch', cs_doc_endpoint, payload, 'application/xml')
	end

	def cs_record_count
		resp = 
			JSON.parse(
				RestClient.get "#{cs_search_endpoint}?q=matchall&q.parser=structured&size=0"
				)
		resp['hits']['found']
	end

	def cs_search_endpoint
		# Search endpoint does not change- store globally
		$cs_search_endpoint ||= 
			"https://#{cs_domain.search_service.endpoint}/2013-01-01/search"
	end

	def cs_doc_endpoint
		# Doc endpoint does not change- store globally
		$cs_doc_endpoint ||= 
			"https://#{cs_domain.doc_service.endpoint}/2013-01-01/documents/batch"	
	end

	def cs_domain(id = nil)
		# Get domain endpoint from AWS
		id ||= ENV['domain']
		cloudsearch = Aws::CloudSearch::Client.new(region: 'us-east-1', 
			credentials: aws_creds('catalog'))
		domain ||= 
			cloudsearch.describe_domains(:domain_names => [ id ]).domain_status_list.find {
		 		|d| d.domain_name == id }
		raise "Domain of name #{domain} was not found" and return if domain.nil?
		return domain
	end
	 


	####
	# S3
	####

	def s3_write_file(bucket, key, content, public = true)
		Aws.config[:ssl_verify_peer] = false
	 
		s3 ||= Aws::S3::Client.new(credentials: aws_creds, region: 'us-east-1')
		s3.put_object(
			acl: 'public-read',
		    key: key,
		    body: content,
		    bucket: bucket,
		    content_type: 'text/plain'
		) 
	end	


	private

	#########
	# General
	#########

	def aws_creds(context = 'digital')
		Aws.config[:ssl_verify_peer] = false
		@creds ||= Aws::Credentials.new(ENV["#{context}_amazonaccesskey"], ENV["#{context}_amazonsecretkey"])
	end	


	def aws_post(service, url, body, content_type)
		headers = sign_request(service, url, 'POST', body, content_type)
	 
	    request =
		    RestClient::Request.new(method: :post, 
		      url: url,
		      payload: body,
		      headers: headers
		      )
	 
		request.execute	
	end
	 
	def sign_request(service, endpoint, method, body, content_type)
		Aws.config[:ssl_verify_peer] = false
	 
		signer = Aws::Signers::V4.new(aws_creds('catalog'), service, 'us-east-1')
		r = 
			Seahorse::Client::Http::Request.new(http_method: method, 
				endpoint: endpoint,
				body: body,
				headers: { 'Content-Type' => content_type}
			)
	 
		r = signer.sign r
		r.headers.to_hash
	end



end