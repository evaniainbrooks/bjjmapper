locations = Location.academies
puts "Searching locationfetchsvc for #{locations.count} academies"
locations.all.each do |loc|
  ::RollFindr::LocationFetchService.search_async(loc.id.to_s)
  puts "Processed #{loc.title}"
  sleep 10
end
