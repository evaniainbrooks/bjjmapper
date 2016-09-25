json.id user.to_param.to_s
json.hash user._id.to_s
json.locations(user.locations) do |location|
  json.title location.title
  json.id location.to_param
  json.loctype location.loctype
end
json.lat user.to_coordinates[0]
json.lng user.to_coordinates[1]
json.favorite_locations(user.favorite_locations) do |location|
  json.title location.title
  json.id location.to_param
  json.loctype location.loctype
end
json.lineal_parent_id user.lineal_parent_id.to_s
json.rank_sort_key User.rank_sort_key(user.belt_rank, user.stripe_rank)
json.full_lineage(user.full_lineage.take(2).reverse) do |user|
  json.id user.to_param
  json.name user.name
end
if user.flag_display_email?
  json.contact_email user.contact_email
end
