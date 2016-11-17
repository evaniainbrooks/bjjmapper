DIRECTORY_CITIES = {
  'Austria' => ['Wien', 'Graz', 'Linz'],
  'Hungary' => ['Budapest', 'Debrecen', 'Miskolc', 'Szeged'],
  'Spain' => ['Madrid', 'Barcelona', 'Valencia', 'Sevilla'],
  'Turkey' => ['Istanbul', 'Izmir', 'Ankara'],
  'USA' => ['San Jose', 'San Antonio', 'Las Vegas', 'Boston', 'Dallas', 'Houston', 'Philadelphia', 'Phoenix', 'Chicago', 'Seattle', 'New York', 'San Francisco', 'Los Angeles', 'Portland'],
  'Canada' => ['Ottawa', 'Vancouver', 'Halifax', 'Toronto', 'Montreal', 'Calgary', 'Edmonton', 'Winnipeg', 'Victoria'],
  'Japan' => ['Tokyo', 'Osaka'],
  'France' => ['Paris', 'Lyon'],
  'United Kingdom' => ['London', 'Manchester'],
  'South Korea' => ['Seoul'],
  'Germany' => ['Berlin', 'Frankfurt', 'Munich', 'Hamburg', 'Cologne', 'Stuttgart', 'Dresden'],
  'Brazil' => ['Rio de Janerio', 'Sao Paulo', 'Belo Horizonte', 'Salvador'],
  'Poland' => ['Warszawa', 'Kraków', 'Wrocław', 'Łódź'],
  'Greece' => ['Athens', 'Thessaloniki', 'Volos'],
  'Sweden' => ['Stockholm', 'Göteborg', 'Malmö'],
  'Finland' => ['Helsinki', 'Tampere'],
  'Russia' => ['Moskva', 'Saint Petersburg', 'Novosibirsk', 'Yekaterinburg'],
  'Mexico' => ['Mexico City', 'Ecatepec', 'Guadalajara', 'Puebla', 'Juárez'],
  'Cyprus' => ['Nicosia']
}.freeze

DIRECTORY_CITIES.each_pair do |seg, cities|
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
