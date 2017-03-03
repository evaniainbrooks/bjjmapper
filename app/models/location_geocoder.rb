class LocationGeocoder
  def self.update(loc)
    if loc.coordinates.present? && loc.address.blank?
      LocationGeocoder.reverse_geocode(loc)
    elsif loc.address.present? && loc.coordinates.blank?
      LocationGeocoder.geocode(loc)
    end
  end

  def self.geocode(loc)
    results = Geocoder.search(loc.address_components.values.join(', '))
    if results.present?
      loc.coordinates = results[0].coordinates.reverse
    end
  end

  def self.reverse_geocode(loc)
    results = Geocoder.search(loc.to_coordinates)
    if results.present?
      loc.street = results[0].street_address
      loc.postal_code = results[0].postal_code
      loc.city = results[0].city
      loc.state = results[0].state
      loc.country = results[0].country
    end
  end
end
