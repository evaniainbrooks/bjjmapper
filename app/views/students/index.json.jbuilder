json.array!(students) do |student|
  json.partial! 'users/user', user: student
end
