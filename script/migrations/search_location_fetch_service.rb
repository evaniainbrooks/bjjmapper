locations = Location.academies
puts "Searching locationfetchsvc for #{locations.count} academies"
locations.all.each do |loc|
  ::RollFindr::LocationFetchService.search_async({location: { id: loc.id.to_s, lat: loc.lat, lng: loc.lng, title: loc.title }})
  puts "Processed #{loc.title}"
  sleep 10
end
