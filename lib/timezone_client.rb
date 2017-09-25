require 'net/http'
require 'uri'

module RollFindr
  class TimezoneClient
    def initialize(host, port)
      @host = host
      @port = port
      @scheme = port.to_i == 443 ? 'https' : 'http'
    end

    def timezone_for(lat, lng)
      query = {lat: lat, lng: lng}.to_query
      uri = URI("#{@scheme}://#{@host}:#{@port}/service/timezone?#{query}")

      get_request(uri)
    end
    
    def get_request(url)
      begin
        http = Net::HTTP.new(url.host, url.port)
        if 'https' == @scheme
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        request = Net::HTTP::Get.new(url.request_uri)
        response = http.request(request) 
        Rails.logger.info "Got response #{response.inspect}"
        
        return nil unless response.code.to_i == 200
          
        response.body
      rescue StandardError => e
        Rails.logger.error e
        nil
      end
    end
  end
end
