json.partial! 'events/event', event: event
json.location do
  json.partial! 'locations/location', location: event.location
end
