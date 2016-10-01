json.id event.to_param
json.title event.title 
json.allDay event.is_all_day || false
json.start event.starting
json.end event.ending
json.description event.description
json.website event.website
json.facebook event.facebook
json.event_type event.event_type
json.event_type_name event.event_type_name
json.recurring event.recurring?
json.recurrence_type event.recurrence_type
json.recurrence_days event.recurrence_days
if event.organization
  json.organization do
    json.partial! 'organizations/organization', organization: event.organization
  end
end
if event.instructor
  json.instructor do
    json.partial! 'instructors/instructor', instructor: event.instructor
  end
end
json.color_ordinal event.color_ordinal
json.duration event.duration
