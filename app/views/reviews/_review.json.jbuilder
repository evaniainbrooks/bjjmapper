json.body review.body
json.created_at distance_of_time_in_words_to_now(review.created_at) + " ago"
json.rating review.rating
json.location_image review.location.try(:image)
json.location_id review.location_id.to_s
json.user_name review.user.name
json.user_link review.user_link
