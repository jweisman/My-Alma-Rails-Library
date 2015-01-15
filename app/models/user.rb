# Adopted from http://richonrails.com/articles/google-authentication-in-ruby-on-rails

class User < ActiveRecord::Base
  
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end
  
  # Add support for user from PDS
  def self.from_pds(bor_info)
    where(provider: "PDS-" + bor_info["bor_id"][0]["institute"][0], 
    	uid: bor_info["bor_id"][0]["id"]).first_or_initialize.tap do |user|
      user.provider = "PDS-" + bor_info["bor_id"][0]["institute"][0]
      user.uid = bor_info["bor_id"][0]["id"][0]
      user.name = bor_info["bor-info"][0]["name"][0]
      user.email = bor_info["bor-info"][0]["email_address"][0]
      user.save!
    end
  end
end