json.id event.to_param
json.title event.title
json.description event.description
json.is_all_day event.is_all_day || false
json.price event.price
json.starting event.starting
json.ending event.ending
json.event_type event.event_type
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
