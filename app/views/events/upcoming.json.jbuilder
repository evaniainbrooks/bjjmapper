json.array!(events) do |event|
  Time.use_zone(event.location.timezone) do
    json.partial! 'events/event_with_location', event: event
  end
end
