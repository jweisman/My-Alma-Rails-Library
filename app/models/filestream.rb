# Code based on s3_cors_fileupload
# https://github.com/batter/s3_cors_fileupload

include S3Helper

class Filestream < ActiveRecord::Base
  belongs_to :deposit

  validates_presence_of :file_name, :file_content_type, :file_size, :key, :bucket, :deposit

  before_validation(:on => :create) do
    self.file_name = key.split('/').last if key
    self.url = get_url
    self.file_size ||= s3_object.content_length rescue nil
    self.file_content_type ||= s3_object.content_type rescue nil
  end

  # cleanup; destroy corresponding file on S3
  after_destroy { 
    delete_file key
  }

  # handle objects with private scope
  after_find :get_url

  def to_jq_upload
    { 
      'id' => id,
      'name' => file_name,
      'size' => file_size,
      'url' => url,
      'image' => self.is_image?,
      'delete_url' => Rails.application.routes.url_helpers.deposit_filestream_path(deposit_id,
        self, :format => :json)
    }
  end

  def is_image?
    !!file_content_type.try(:match, /image/)
  end

  def s3_object
    @s3_object ||= head_object (key) if key
    rescue nil 
  end

end
