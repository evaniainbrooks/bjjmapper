require 'net/http'
require 'uri'

module RollFindr
  class LocationFetchClient
    API_KEY = "d72d574f-a395-419e-879c-2b2d39a51ffc"
    SERVICE_PATH = "service/fetch"

    def initialize(host, port)
      @host = host
      @port = port
      @scheme = port.to_i == 443 ? 'https' : 'http'
    end

    def associate(location_id, opts = {})
      query = common_params.merge(opts.slice(:scope, :foursquare_id, :yelp_id, :facebook_id, :google_id)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/associate?#{query}")

      response = post_request(uri, nil)
      response.nil? ? 500 : response.code.to_i
    end

    def search(location_id, location_data, params = {})
      query = common_params.merge(params.slice(:scope))
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/search?#{query.to_query}")

      response = post_request(uri, location_data.to_json)
      response.nil? ? 500 : response.code.to_i
    end

    def search_near(location_data, params = {})
      query = common_params.merge(params.slice(:scope))
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/search?#{query.to_query}")

      response = post_request(uri, location_data.to_json)
      response.nil? ? 500 : response.code.to_i
    end
    
    def photos_near(params = {})
      query = common_params.merge(params.slice(:lat, :lng, :distance, :count, :scope)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/photos?#{query}")

      get_request(uri)
    end
    
    def reviews_near(params = {})
      query = common_params.merge(params.slice(:lat, :lng, :distance, :count, :scope)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/reviews?#{query}")

      get_request(uri)
    end

    def all_listings(location_id, opts = {})
      query = common_params.merge(params.slice(:title, :lat, :lng, :street, :city, :state, :country, :postal_code, :scope)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/listings?#{query}")

      get_request(uri)
    end

    def photos(location_id, opts = {})
      query = common_params.merge(opts.slice(:scope, :count)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/photos?#{query}")

      get_request(uri)
    end

    def reviews(location_id, opts = {})
      query = common_params.merge(opts.slice(:scope, :count)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}/reviews?#{query}")

      get_request(uri)
    end

    def listings(location_id, params = {})
      query = common_params.merge(params.slice(:title, :lat, :lng, :street, :city, :state, :country, :postal_code, :combined, :scope)).to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/#{SERVICE_PATH}/locations/#{location_id}?#{query}")

      get_request(uri)
    end

    private

    def common_params
      { api_key: API_KEY }
    end

    def post_request(uri, body)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if 'https' == @scheme
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body 
      request.content_type = 'application/json'

      begin
        response = http.request(request)
        response
      rescue StandardError => e
        Rails.logger.error e.message
        nil
      end
    end

    def get_request(uri)
      begin
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true if 'https' == @scheme
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request) 
        Rails.logger.info "Got response #{response.inspect}"
        
        return nil unless response.code.to_i == 200

        result = JSON.parse(response.body)
        if result.is_a?(Array)
          result.map {|h| h.deep_symbolize_keys}
        else
          result.deep_symbolize_keys
        end
      rescue StandardError => e
        Rails.logger.error e.message
        nil
      end
    end
  end
end
