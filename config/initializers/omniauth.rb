Rails.application.config.middleware.use OmniAuth::Builder do
  #require 'openid/store/filesystem'
  #provider :openid, :store => OpenID::Store::Filesystem.new('/tmp')
  provider :google_oauth2, ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_CLIENT_SECRET']
  provider :facebook, ENV['FACEBOOK_CLIENT_ID'], ENV['FACEBOOK_CLIENT_SECRET']
  provider :twitter, ENV['TWITTER_CLIENT_ID'], ENV['TWITTER_CLIENT_SECRET']
  provider :identity, :fields => [:email, :name], :on_failed_registration => SessionsController.action(:new)
end
