OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['googleclientid'], ENV['googleclientsecret'], {client_options: {ssl: {ca_file: Rails.root.join("cacert.pem").to_s}}}
end