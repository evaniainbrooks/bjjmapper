require 'geocoder'

Geocoder.configure(
  ip_lookup: :google,
  timeout: 7,
  use_https: true,
  api_key: ENV['GOOGLE_GEOCODER_API_KEY'],
  cache: Redis.new(:host => Rails.application.config.redis_host, :password => Rails.application.config.redis_password),
  cache_prefix: 'geocoder-google'
)

