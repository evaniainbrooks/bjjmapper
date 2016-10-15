json.geocode_results(@geocoder_results) do |result|
  json.partial! 'geocoders/geocoder_result', result: result
end
json.locations(locations) do |location|
  json.partial! 'locations/location', location: location
end
