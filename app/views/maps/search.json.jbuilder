json.array! @locations do |location|
  json.partial! 'locations/location', location: location
  json.instructors location.instructors, partial: 'instructors/instructor', as: :instructor
  json.events location.events, partial: 'events/event', as: :event
end
