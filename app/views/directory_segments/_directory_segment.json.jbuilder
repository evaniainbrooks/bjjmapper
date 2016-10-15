json.id directory_segment.id.try(:to_s)
json.name directory_segment.name
json.full_name directory_segment.full_name
json.parent_segment directory_segment.parent_segment_id
json.abbreviations directory_segment.abbreviations
json.description directory_segment.description
json.distance directory_segment.distance
json.zoom directory_segment.zoom
json.timezone directory_segment.timezone
json.lat directory_segment.lat
json.lng directory_segment.lng
json.synthetic directory_segment.synthetic
json.locations(directory_segment.locations) do |location|
  json.partial! 'locations/location', location: location
end
json.child_segments(directory_segment.child_segments) do |segment|
  json.partial! 'directory_segments/directory_segment', directory_segment: segment
end
