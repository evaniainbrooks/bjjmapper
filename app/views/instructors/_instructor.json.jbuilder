json.id instructor.to_param
json.name instructor.name
json.belt_rank instructor.belt_rank
json.stripe_rank instructor.stripe_rank
json.image_large instructor.image_large
json.image instructor.image
json.image_tiny instructor.image_tiny
json.description instructor.description
json.full_lineage(instructor.full_lineage) do |instructor|
  json.name instructor.name
  json.id instructor.to_param
  json.image instructor.image
  json.image_tiny instructor.image_tiny
  json.description instructor.description
end
