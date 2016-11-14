json.partial! 'directory_segments/directory_segment', directory_segment: directory_segment
json.locations(directory_segment.locations) do |location|
  json.partial! 'locations/location', location: location
end
