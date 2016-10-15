json.id instructor.id.try(:to_s)
json.param instructor.to_param.to_s
json.name instructor.name
json.belt_rank instructor.belt_rank
json.stripe_rank instructor.stripe_rank
json.image_large instructor.image_large
json.image instructor.image
json.image_tiny instructor.image_tiny
json.description instructor.description
json.full_lineage(instructor.full_lineage.take(2).reverse) do |instructor|
  json.name instructor.name
  json.id instructor.to_param
  json.image instructor.image
  json.image_tiny instructor.image_tiny
  json.description instructor.description
end
