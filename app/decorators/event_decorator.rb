class EventDecorator < Draper::Decorator
  delegate_all
  decorates_finders

  def duration
    s = object.starting.strftime('%l:%M%p').strip()
    e = object.ending.strftime('%l:%M%p').strip()
    "#{s}-#{e}"
  end

  def as_json(args)
    object.as_json(args).merge(
      duration: duration
    )
  end
end
