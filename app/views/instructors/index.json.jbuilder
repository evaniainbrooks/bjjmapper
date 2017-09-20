json.array!(location_or_team.instructors) do |instructor|
  json.partial! 'users/user', user: instructor
end
