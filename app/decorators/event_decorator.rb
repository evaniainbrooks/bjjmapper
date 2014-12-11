class EventDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def duration
    s = object.starting.try(:strftime, '%l:%M%p').try(:strip)
    e = object.ending.try(:strftime, '%l:%M%p').try(:strip)
    "#{s}-#{e}"
  end

  def as_json(args)
    object.as_json(args).merge(
      duration: duration
    )
  end
end
