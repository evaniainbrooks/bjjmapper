json.body review.body
json.created_at distance_of_time_in_words_to_now(review.created_at) + " ago"
json.rating review.rating
json.location_image review.location.try(:image)
json.location_id review.location_id.to_s
json.location_name review.location.try(:title)
json.attribution_name review.attribution_name
json.attribution_link review.attribution_link
json.src review.src
