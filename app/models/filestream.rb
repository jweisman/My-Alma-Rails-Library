# Code based on s3_cors_fileupload
# https://github.com/batter/s3_cors_fileupload

class Filestream 
  include ActiveModel::Model
  include S3Helper

  require 'base64'

  attr_accessor :file_name, :file_size, :key, :url

  def initialize(attributes={})
    super
    self.file_name ||= key.split('/').last if key
    self.url = get_url(key) if key
  end

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def to_jq_upload
    { 
      #'id' => id,
      'name' => file_name,
      'size' => file_size,
      'url' => url,
      'image' => self.is_image?,
      'delete_url' => Rails.application.routes.url_helpers.deposit_filestream_path(Base64.encode64(self.file_name), :format => :json)
    }
  end

  def is_image?
    !!file_name.try(:match, '[^\s]+(\.(?i)(jpg|png|gif|bmp))$')
  end

end
