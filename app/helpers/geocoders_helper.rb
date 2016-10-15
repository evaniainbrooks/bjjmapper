require 'ostruct'

module GeocodersHelper
  def self.search(search_query)
    Geocoder.search(search_query).map do |r|
      OpenStruct.new({
        address: r.address,
        street: r.street_address,
        postal_code: r.postal_code,
        city: r.city,
        state: r.state,
        country: r.country
      }.merge(r.geometry['location']))
    end
  end
end
