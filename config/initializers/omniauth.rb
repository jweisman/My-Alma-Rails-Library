OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['googleclientid'], ENV['googleclientsecret'], {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :saml,
    :issuer                             => "my-alma-rails-library",
    :idp_sso_target_url                 => "https://exlibris.onelogin.com/trust/saml2/http-post/sso/458700",
    :idp_cert_fingerprint               => "A5:4A:77:86:60:B8:19:E4:62:F5:83:F8:83:64:06:E0:5A:AC:4C:54",
    :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
end

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :jwt,
		:secret 		=>	ENV['alma_auth_secret'],
		:auth_url		=>	"https://#{ENV['alma']}.alma.exlibrisgroup.com/view/socialLogin?institutionCode=#{ENV['institution']}&backUrl=#{ENV['root_url']}/auth/jwt/callback",
		:uid_claim 	=> 	"id",
		:required_claims 	=> ['id']
end
