json.partial! 'locations/location', location: location
json.event_count location.events.try(:count) || 0
json.events location.events, partial: 'events/event', as: :event
