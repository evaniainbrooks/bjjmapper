json.id location.id.try(:to_s)
json.param location.to_param
json.loctype location.loctype
json.status location.status
json.title location.title
if location.object
  json.venue_title location.object.title
end
json.team_name location.team_name
json.team_id location.team.try(:to_param)
json.website location.website.try(:strip) || ''
json.phone location.phone || ''
json.email location.email || ''
json.facebook location.facebook || ''
json.instagram location.instagram || ''
json.twitter location.twitter || ''
json.distance location.try(:distance) || ''
json.bearing location.try(:bearing)
json.bearing_direction location.try(:bearing_direction)
json.city location.city
json.country location.country
json.state location.state || ''
json.postal_code location.postal_code
json.street location.street || ''
json.address location.address
json.timezone location.timezone
json.dates location.try(:dates)
json.lat location.lat
json.lng location.lng
json.link location.try(:link)
json.entities location.try(:entities)
json.entities_abbreviations location.try(:entities_abbreviations)
json.event_count location.events.try(:count) || 0
json.image location.image
json.image_large location.try(:image_large)
json.image_tiny location.try(:image_tiny)
json.has_black_belt location.flag_has_black_belt || false
json.flag_closed location.flag_closed || false
json.created_at location.created_at
json.updated_at location.updated_at
json.rating location.rating
json.review_count location.all_reviews.items.count
json.stars location.stars
json.half_star location.half_star?
if location.respond_to?(:yelp_url)
  json.yelp_url location.yelp_url
  json.google_url location.google_url
  json.facebook_url location.facebook_url
end
