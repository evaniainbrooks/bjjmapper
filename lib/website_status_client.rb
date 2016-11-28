require 'net/http'
require 'uri'

module RollFindr
  class WebsiteStatusClient
    API_KEY = "d72d574f-a395-419e-879c-2b2d39a51ffc"
    SERVICE_PATH = "service/website"

    def initialize(host, port)
      @host = host
      @port = port
    end

    def status(params)
      query = {api_key: API_KEY, url: params[:url], location_id: params[:location_id]}
      uri = URI("http://#{@host}:#{@port}/#{SERVICE_PATH}/status?#{query.to_query}")
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
