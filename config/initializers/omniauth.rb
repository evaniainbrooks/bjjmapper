Rails.application.config.middleware.use OmniAuth::Builder do
  #require 'openid/store/filesystem' 
  #provider :openid, :store => OpenID::Store::Filesystem.new('/tmp')
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET'] 
end
