json.id result.id.to_s
json.title result.title
json.street result.street
json.city result.city
json.country result.country
json.lat result.lat
json.lng result.lng
json.url location_path(result, ref: 'search')
