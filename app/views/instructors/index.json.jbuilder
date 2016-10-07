json.array!(instructors) do |instructor|
  json.partial! 'users/user', user: instructor
end
