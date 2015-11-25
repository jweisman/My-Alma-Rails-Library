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

	def get_files(path)
		@s3.list_objects(
			bucket: ENV['amazonbucket'],
			prefix: path
		) if aws_connect
	end
	
	def get_url(key)
	  signer ||= Aws::S3::Presigner.new(client: @s3) if aws_connect
	  self.url = signer.presigned_url(:get_object, 
	    bucket: ENV['amazonbucket'], key: key)
	end	
	
	def head_object(key)
	    @s3.head_object(bucket: ENV['amazonbucket'], key: key) if aws_connect
	end	

	def aws_connect
		Aws.config[:ssl_verify_peer] = false
		creds = Aws::Credentials.new(ENV['digital_amazonaccesskey'], ENV['digital_amazonsecretkey'])
		@s3 ||= Aws::S3::Client.new(credentials: creds, region: ENV['amazonregion'])
	end
end
