require 'net/http'
require 'uri'

module RollFindr
  class TimezoneClient
    def initialize(host, port)
      @host = host
      @port = port
    end

    def timezone_for(lat, lng)
      query = {lat: lat, lng: lng}.to_query
      uri = URI("http://#{@host}:#{@port}/service/timezone?#{query}")
      
      begin 
        response = Net::HTTP.get_response(uri)
        return nil if response.code.to_i != 200
        response.body
      rescue StandardError => e
        puts e.message
        nil
      end
    end
  end
end
