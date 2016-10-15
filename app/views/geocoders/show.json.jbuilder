json.array! @search_results do |result|
  json.partial! 'geocoders/geocoder_result', result: result
end
