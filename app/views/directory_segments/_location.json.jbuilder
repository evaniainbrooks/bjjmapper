json.id location.to_param
json.title location.title
json.team_name location.team_name
json.team_id location.team.try(:to_param)
json.website location.website.try(:strip) || ''
json.email location.email || ''
json.address location.address
json.coordinates location.to_coordinates
json.instructors location.instructors do |instructor|
  json.id instructor.to_param
  json.name instructor.name
  json.belt_rank instructor.belt_rank
  json.stripe_rank instructor.stripe_rank
end

