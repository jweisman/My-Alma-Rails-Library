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

	def aws_connect
		Aws.config[:ssl_verify_peer] = false
		creds = Aws::Credentials.new(ENV['amazonaccesskey'], ENV['amazonsecretkey'])
		@s3 ||= Aws::S3::Client.new(credentials: creds, region: 'us-east-1')
	end
end
