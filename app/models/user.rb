# Adapted from http://richonrails.com/articles/google-authentication-in-ruby-on-rails


class User 
  include ActiveModel::Model

  attr_accessor :provider, :id, :name, :email
  def initialize(attributes)
    super
  end

  # Handle either OAuth or SAML
  def self.from_omniauth(auth)
    self.new({
    provider: auth.provider,
    id: auth.uid,
    name: auth.info.name || auth.extra.raw_info["User.FirstName"] + " " + auth.extra.raw_info["User.LastName"],
    email: auth.info.email || auth.extra.raw_info["User.email"]
    })
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