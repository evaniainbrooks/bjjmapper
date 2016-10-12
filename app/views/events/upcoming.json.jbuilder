json.array!(events) do |event|
  json.partial! 'events/event_with_location', event: event
end
