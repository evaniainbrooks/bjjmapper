json.partial! 'locations/location', location: location
json.instructors location.instructors, partial: 'users/user', as: :user
