require 'net/http'
require 'uri'

module RollFindr
  class LocationFetchClient
    API_KEY = "d72d574f-a395-419e-879c-2b2d39a51ffc"
    SERVICE_PATH = "service/fetch"

    def initialize(host, port)
      @host = host
      @port = port
    end

    def search_async(location_data, scope = nil)
      query = {api_key: API_KEY}
      query.merge(scope: scope) if scope.present?
      uri = URI("http://#{@host}:#{@port}/#{SERVICE_PATH}/search/async?#{query.to_query}")

      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = location_data.to_json

      begin
        response = http.request(request)
        response.code
      rescue StandardError => e
        Rails.logger.error e.message
        500
      end
    end

    def photos(location_id)
      query = {api_key: API_KEY}.to_query
      uri = URI("http://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/photos?#{query}")

      get_request(uri)
    end

    def reviews(location_id)
      query = {api_key: API_KEY}.to_query
      uri = URI("http://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/reviews?#{query}")

      get_request(uri)
    end

    def detail(location_id)
      query = {api_key: API_KEY}.to_query
      uri = URI("http://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/detail?#{query}")

      get_request(uri)
    end

    private

    def get_request(uri)
      begin
        response = Net::HTTP.get_response(uri)
        return nil unless response.code.to_i == 200

        JSON.parse(response.body).deep_symbolize_keys
      rescue StandardError => e
        Rails.logger.error e.message
        nil
      end
    end
  end
end
