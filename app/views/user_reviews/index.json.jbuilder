json.array!(reviews) do |review|
  json.partial! 'location_reviews/review', review: review
end
