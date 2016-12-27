json.rating @response.rating
json.stars @response.stars
json.half_star @response.half_star
json.summary @response.summary
json.review_count @response.review_count
json.reviews(@response.reviews) do |review|
  json.partial! 'location_reviews/review', review: review
end
