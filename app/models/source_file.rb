#require 'aws/s3'
require 'aws-sdk-core'

class SourceFile < ActiveRecord::Base
  belongs_to :deposit
  # This line can be removed for Rails 4 apps that are using Strong Parameters
  attr_accessible :url, :bucket, :key if S3CorsFileupload.active_record_protected_attributes?

  validates_presence_of :file_name, :file_content_type, :file_size, :key, :bucket, :deposit

  before_validation(:on => :create) do
    self.file_name = key.split('/').last if key
    # for some reason, the response from AWS seems to escape the slashes in the keys, this line will unescape the slash
    # self.url = url.gsub(/%2F/, '/') if url
    self.url = get_url
    self.file_size ||= s3_object.content_length rescue nil
    self.file_content_type ||= s3_object.content_type rescue nil
  end
  # make all attributes readonly after creating the record (not sure we need this?)
  after_create { readonly! }
  # cleanup; destroy corresponding file on S3
  after_destroy { s3_object.try(:delete) }

  # handle objects with private scope
  after_find :get_url

  def to_jq_upload
    { 
      'id' => id,
      'name' => file_name,
      'size' => file_size,
      'url' => url,
      'image' => self.is_image?,
      'delete_url' => Rails.application.routes.url_helpers.deposit_source_file_path(deposit_id,
        self, :format => :json)
    }
  end

  def is_image?
    !!file_content_type.try(:match, /image/)
  end

  #---- start S3 related methods -----
  # changed to aws-sdk since the aws-s3 find method wasn't working with a limited permissions user
  # (it needed additional list bucket permissions)
  def s3_object
    @s3_object ||= @s3.head_object(bucket: bucket, key: key) if open_aws && key
  rescue 
    nil 
  end

  def get_url
    signer ||= Aws::S3::Presigner.new(client: @s3) if open_aws
    self.url = signer.presigned_url(:get_object, 
      bucket: bucket, key: key)
  end

  def open_aws
    Aws.config[:ssl_verify_peer] = false
    creds = Aws::Credentials.new(S3CorsFileupload::Config.access_key_id,
      S3CorsFileupload::Config.secret_access_key)
    @s3 ||= Aws::S3::Client.new(credentials: creds, region: 'us-east-1')
  end
  #---- end S3 related methods -----

end
