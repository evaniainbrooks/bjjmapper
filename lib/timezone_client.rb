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
      response = Net::HTTP.get_response(uri)
      response.body
    end
  end
end
