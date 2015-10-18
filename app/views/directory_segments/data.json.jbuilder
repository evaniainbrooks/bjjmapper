json.locations @locations do |location|
  json.partial! 'directory_segments/location', location: location
end
json.total_count @total_count
json.page_count @page_count
