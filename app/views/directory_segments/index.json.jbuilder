json.array!(@directory_segments.keys) do |country|
  json.partial! 'directory_segments/directory_segment', directory_segment: country
  json.child_segments(@directory_segments[country]) do |segment|
    json.partial! 'directory_segments/directory_segment', directory_segment: segment
  end
end
