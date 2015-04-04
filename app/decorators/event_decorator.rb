class EventDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :location

  OPEN_MAT_COLOR_ORDINAL = 888
  GUEST_INSTRUCTOR_COLOR_ORDINAL = 999 

  def duration
    s = object.starting.try(:strftime, '%l:%M%p').try(:strip)
    e = object.ending.try(:strftime, '%l:%M%p').try(:strip)
    "#{s}-#{e}"
  end

  def as_json(args)
    object.as_json(args).merge(
      location_name: location.title,
      location_image: location.image,
      duration: duration,
      color_ordinal: color_ordinal,
      instructor_name: instructor.try(:name)
    )
  end

  private

  def color_ordinal
    location.instructor_color_ordinal(instructor)
  end
end
