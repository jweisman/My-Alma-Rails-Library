OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['googleclientid'], ENV['googleclientsecret'], 
  	{
  		client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}},
      skip_jwt: true
  	}

  provider :saml,
    :issuer                             => "my-alma-rails-library",
    :idp_sso_target_url                 => "https://exlibris.onelogin.com/trust/saml2/http-post/sso/458700",
    :idp_cert_fingerprint               => "A5:4A:77:86:60:B8:19:E4:62:F5:83:F8:83:64:06:E0:5A:AC:4C:54",
    :name_identifier_format             => "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

	provider :jwt,
    :setup => lambda{|env|
      req = Rack::Request.new(env)
      if req.params['from']=='primo'
        # Get public key with API
        env['omniauth.strategy'].options[:secret]     = "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE0jKK/Zt3NxAxmEgxCox+UJprj+xGm/+00pdTmwiPjw8PxhCf9m6b3tV+mM3xCiMiuDOn7GJ6hSIf296Ap9998w==\n-----END PUBLIC KEY-----"
        env['omniauth.strategy'].options[:uid_claim]  =  "userName"
        env['omniauth.strategy'].options[:required_claims]  = ['userName']
        env['omniauth.strategy'].options[:algorithm] = 'ES256'        
        env['omniauth.strategy'].options[:verify]     = false # Temporary until Primo supports getting the public key
      else
        env['omniauth.strategy'].options[:secret]     =  ENV['alma_auth_secret']
        env['omniauth.strategy'].options[:uid_claim]  =  "id"
        env['omniauth.strategy'].options[:required_claims]  = ['id']        
      end
      env['omniauth.strategy'].options[:auth_url]   =  "https://#{ENV['alma']}.alma.exlibrisgroup.com/view/socialLogin?institutionCode=#{ENV['institution']}&backUrl=#{ENV['root_url']}/auth/jwt/callback"
    }
end
