json.id event.id.try(:to_s)
json.param event.to_param.try(:to_s)
json.location_id event.location_id.to_s
json.link location_event_path(event.location, event)
json.title event.title
json.image event.image
json.image_large event.image_large
json.description event.description
json.is_all_day event.is_all_day || false
json.price event.price
json.starting event.starting
json.ending event.ending
json.event_type event.event_type
json.event_type_name event.event_type_name
json.schedule_in_words event.schedule.try(:to_s)
json.website event.website
json.facebook event.facebook
json.recurring event.recurring?
json.organization do
  if event.organization.present?
    json.partial! 'organizations/organization', organization: event.organization
  end
end
json.instructor do
  if event.instructor.present?
    json.partial! 'instructors/instructor', instructor: event.instructor
  end
end
