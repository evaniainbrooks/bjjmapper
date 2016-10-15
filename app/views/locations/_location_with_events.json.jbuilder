json.partial! 'locations/location', location: location
json.events location.events, partial: 'events/event', as: :event
