RollFindr::DirectoryCities.each_pair do |seg, cities|
  seg = DirectorySegment.find(seg.downcase.parameterize)
  cities.each do |city|
    seg.child_segments << DirectorySegment.new do |cs|
      cs.name = city
      puts "Geocoding #{city}, #{seg.name}"
      result = Geocoder.search("#{city}, #{seg.name}")
      cs.coordinates = [result[0].geometry['location']['lng'], result[0].geometry['location']['lat']]
      cs.save
    end
  end
end
