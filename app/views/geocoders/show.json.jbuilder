json.array! @search_results do |result|
  json.address result.address
  json.street result.street_address
  json.postal_code result.postal_code
  json.city result.city
  json.state result.state
  json.country result.country
  json.lat result.geometry['location']['lat']
  json.lng result.geometry['location']['lng']
end
