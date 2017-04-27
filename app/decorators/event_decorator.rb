class EventDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'

  delegate_all
  decorates_finders
  decorates_association :location
  decorates_association :instructor
  decorates_association :organization

  def duration
    s = object.starting.try(:strftime, '%l:%M%p').try(:strip)
    e = object.ending.try(:strftime, '%l:%M%p').try(:strip)
    "#{s}-#{e}"
  end

  def event_type_name
    return h.event_type_name(object.event_type)
  end

  def image
    organization.try(:image) || instructor.try(:image) || location.try(:image)
  end

  def image_large
    organization.try(:image_large) || instructor.try(:image_large) || location.try(:image_large)
  end

  def description
    if object.description.present?
      object.description
    else
      if (object.event_type != Event::EVENT_TYPE_CLASS)
        generated_description
      else
        h.content_tag(:i, class: 'text-muted') { DEFAULT_DESCRIPTION }
      end
    end
  end

  def color_ordinal
    location.instructor_color_ordinal(instructor)
  end

  private

  def generated_description
    venue_link = h.link_to(object.location.title, h.map_path(zoom: Map::ZOOM_LOCATION, lat: object.location.lat, lng: object.location.lng))

    "The '#{object.title}' is a #{event.organization.abbreviation} Brazilian Jiu-Jitsu #{event_type_name} taking place on #{object.schedule.to_s} at #{venue_link}. For more information, visit the #{h.link_to('tournament website', 'http://' + object.website)}.".html_safe
  end
end
