json.body review.body
json.created_at distance_of_time_in_words_to_now(review.created_at) + " ago"
json.rating review.rating
json.location_image review.location.try(:image)
json.location_id review.location_id.to_s
json.location_name review.location.try(:title)
if review.user.present?
  json.author_name review.user.name
  json.author_link user_path(review.user)
else
  json.author_name review.author_name
  json.author_link review.author_link
end
json.src review.src || 'BJJMapper'
json.src_id review.src_id
json.src_group_id review.src_group_id
