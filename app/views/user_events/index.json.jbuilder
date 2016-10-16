json.array!(events) do |event|
  json.partial! 'location_events/event', event: event
end
