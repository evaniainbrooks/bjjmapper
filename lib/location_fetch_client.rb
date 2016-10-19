require 'net/http'
require 'uri'

module RollFindr
  class LocationFetchClient
    API_KEY = "d72d574f-a395-419e-879c-2b2d39a51ffc"

    def initialize(host, port)
      @host = host
      @port = port
    end

    def search_async(location_id)
      query = {location_id: location_id, api_key: API_KEY}.to_query
      uri = URI("http://#{@host}:#{@port}/places/search/async?#{query}")

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      response = http.request(request)
      response.code
    end
  end
end
