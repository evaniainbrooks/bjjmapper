json.id user.id.try(:to_s)
json.param user.to_param.to_s
json.name user.name
json.nickname user.nickname
json.description user.description
json.locations(user.locations) do |location|
  json.title location.title
  json.id location.to_param
  json.loctype location.loctype
end
json.image user.image
json.image_tiny user.image_tiny
json.image_large user.image_large
json.thumbnailx user.thumbnailx
json.thumbnaily user.thumbnaily
json.lat user.to_coordinates[0]
json.lng user.to_coordinates[1]
json.favorite_locations(user.favorite_locations) do |location|
  json.title location.title
  json.id location.to_param
  json.loctype location.loctype
end
json.is_anonymous user.anonymous?
json.belt_rank user.belt_rank
json.stripe_rank user.stripe_rank
json.lineal_parent_id user.lineal_parent_id.to_s
json.rank_sort_key User.rank_sort_key(user.belt_rank, user.stripe_rank)
json.full_lineage(user.full_lineage.take(2).reverse) do |user|
  json.id user.to_param
  json.name user.name
end
if user.flag_display_email?
  json.contact_email user.contact_email
end
json.rank_in_words user.try(:rank_in_words)
