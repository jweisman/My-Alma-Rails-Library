# Code from from s3_cors_fileupload
# https://github.com/batter/s3_cors_fileupload

require 'base64'
require 'openssl'
require 'digest/sha1'
require 'multi_json'

  class S3PolicyHelper
    attr_reader :options

    def initialize(_options = {})
      # default max_file_size to 500 MB if nothing is received
      @options = {
        :acl => 'public-read',
        :max_file_size => ENV['amazonmaxfilesize'] || 524288000,
        :bucket => ENV['amazonbucket']
      }.merge(_options).merge(:secret_access_key => ENV['amazonsecretkey'])
    end

    # generate the policy document that amazon is expecting.
    def policy_document
      @policy_document ||=
        Base64.encode64(
          MultiJson.dump(
            {
              expiration: 10.hours.from_now.utc.iso8601(3),
              conditions: [
                { bucket: options[:bucket] },
                { acl: options[:acl] },
                { success_action_status: '201' },
                ["content-length-range", 0, options[:max_file_size]],
                ["starts-with", "$utf8", ""],
                ["starts-with", "$key", ""],
                ["starts-with", "$Content-Type", ""]
              ]
            }
          )
        ).gsub(/\n/, '')
    end

    # sign our request by Base64 encoding the policy document.
    def upload_signature
      @upload_signature ||=
        Base64.encode64(
          OpenSSL::HMAC.digest(
            OpenSSL::Digest::SHA1.new,
            ENV['amazonsecretkey'],
            self.policy_document
          )
        ).gsub(/\n/, '')
    end
  end
