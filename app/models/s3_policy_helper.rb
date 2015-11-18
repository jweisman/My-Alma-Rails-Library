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
      short_date = Time.now.strftime("%Y%m%d")
      @options = {
        :acl => 'public-read',
        :max_file_size => ENV['amazonmaxfilesize'] || 524288000,
        :bucket => ENV['amazonbucket'],
        :region => ENV['amazonregion'], 
        :amz_date_short => short_date,
        :amz_date => Time.now.strftime("%Y%m%dT000000Z"),
        :amz_credential => "#{ENV['digital_amazonaccesskey']}/#{short_date}/#{ENV['amazonregion']}/s3/aws4_request"
      }.merge(_options).merge(:secret_access_key => ENV['digital_amazonsecretkey'])
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
                ["starts-with", "$Content-Type", ""],
                { "x-amz-credential": options[:amz_credential] },
                { "x-amz-algorithm": "AWS4-HMAC-SHA256" }, 
                { "x-amz-date": options[:amz_date] }
              ]
            }
          )
        ).gsub(/\n/, '')
    end

    # sign request - Amazon signature version 4
    def upload_signature
      @upload_signature ||=
        bin_to_hex(
          OpenSSL::HMAC.digest(
            'sha256',
            getSignatureKey(ENV['digital_amazonsecretkey'], 
              options[:amz_date_short],
              options[:region],
              's3'),
            self.policy_document
            )
          )
    end

    def getSignatureKey key, dateStamp, regionName, serviceName
      kDate    = OpenSSL::HMAC.digest('sha256', "AWS4" + key, dateStamp)
      kRegion  = OpenSSL::HMAC.digest('sha256', kDate, regionName)
      kService = OpenSSL::HMAC.digest('sha256', kRegion, serviceName)
      kSigning = OpenSSL::HMAC.digest('sha256', kService, "aws4_request")

      kSigning
    end

    # from http://anthonylewis.com/2011/02/09/to-hex-and-back-with-ruby/
    def bin_to_hex(s)
      s.each_byte.map { |b| b.to_s(16) }.join
    end   

  end
