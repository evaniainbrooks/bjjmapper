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
      request.body = ""

      begin
        response = http.request(request)
        response.code
      rescue StandardError => e
        logger.error e.message
        500
      end
    end

    def reviews(location_id)
      query = {location_id: location_id, api_key: API_KEY}.to_query
      uri = URI("http://#{@host}:#{@port}/places/reviews?#{query}")

      get_request(uri)
    end

    def detail(location_id)
      query = {location_id: location_id, api_key: API_KEY}.to_query
      uri = URI("http://#{@host}:#{@port}/places/detail?#{query}")

      get_request(uri)
    end

    private

    def get_request(uri)
      begin
        response = Net::HTTP.get_response(uri)
        return nil unless response.code.to_i == 200

        JSON.parse(response.body).deep_symbolize_keys
        response.code
      rescue StandardError => e
        logger.error e.message
        nil
      end
    end
  end
end
