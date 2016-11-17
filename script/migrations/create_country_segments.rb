DIRECTORY_COUNTRIES =  {
  'Austria' => 'AT',
  'Canada' => 'CA',
  'Cyprus' => 'CY',
  'Germany' => 'DE',
  'Greece' => 'GR',
  'France' => 'FR',
  'Poland' => 'PL',
  'United Kingdom' => 'UK',
  'USA' => 'US',
  'Brazil' => 'BR',
  'Japan' => 'JP',
  'South Korea' => 'KR',
  'Spain' => 'ES',
  'Turkey' => 'TR',
  'Hungary' => 'HU',
  'Sweden' => 'SE',
  'Finland' => 'FI',
  'Russia' => 'RU',
  'Mexico' => 'MX'
}.freeze

DIRECTORY_COUNTRIES.each_pair do |name, abv|
  DirectorySegment.new do |seg|
    seg.name = name
    seg.abbreviations = [abv]
    puts "Geocoding #{name}"
    result = Geocoder.search(seg.name)
    seg.coordinates = [result[0].geometry['location']['lng'], result[0].geometry['location']['lat']]
    seg.save
  end
end
