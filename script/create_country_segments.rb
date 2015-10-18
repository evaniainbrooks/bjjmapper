RollFindr::DirectoryCountries.each_pair do |name, abv|
  DirectorySegment.new do |seg|
    seg.name = name
    seg.abbreviations = [abv]
    puts "Geocoding #{name}"
    result = Geocoder.search(seg.name)
    seg.coordinates = [result[0].geometry['location']['lng'], result[0].geometry['location']['lat']]
    seg.save
  end
end
