module S3Helper
require 'aws-sdk-core'

	def write_file(key, content)
		@s3.put_object(
	        key: key,
	        body: content,
	        bucket: ENV['amazonbucket'],
	        content_type: 'text/plain'
		) if aws_connect
	end

	def delete_file(key)
		@s3.delete_object(
			key: key,
			bucket: ENV['amazonbucket']
		) if aws_connect
	end
	
	def get_url
	  signer ||= Aws::S3::Presigner.new(client: @s3) if aws_connect
	  self.url = signer.presigned_url(:get_object, 
	    bucket: bucket, key: key)
	end	
	
	def head_object(key)
	    @s3.head_object(bucket: ENV['amazonbucket'], key: key) if aws_connect
	end	

	def aws_connect
		Aws.config[:ssl_verify_peer] = false
		creds = Aws::Credentials.new(ENV['amazonaccesskey'], ENV['amazonsecretkey'])
		@s3 ||= Aws::S3::Client.new(credentials: creds, region: 'us-east-1')
	end
end
