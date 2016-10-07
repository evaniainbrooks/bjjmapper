json.id user.to_param.to_s
json.hash user._id.to_s
json.name user.name
json.lat user.to_coordinates[0]
json.lng user.to_coordinates[1]
json.favorite_locations(user.favorite_locations) do |location|
  json.title location.title
  json.id location.to_param
  json.loctype location.loctype
end
json.is_anonymous user.anonymous?
if user.flag_display_email?
  json.contact_email user.contact_email
end
