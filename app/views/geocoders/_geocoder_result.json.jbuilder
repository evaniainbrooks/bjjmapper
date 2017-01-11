json.address result.address
json.street result.street
json.postal_code result.postal_code
json.city result.city
json.state result.state
json.country result.country
json.lat result.lat
json.lng result.lng
json.url map_path(lat: result.lat, lng: result.lng, ref: 'search')
