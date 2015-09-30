require 'geocoder'

Geocoder.configure(
  ip_lookup: :google,
  timeout: 7,
  use_https: true,
  api_key: ENV['GOOGLE_GEOCODER_API_KEY'],
  cache: Redis.new,
  cache_prefix: 'geocoder-google'
)

