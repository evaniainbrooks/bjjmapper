module EventsHelper
  def event_type_name(event_type)
    case event_type
    when Event::EVENT_TYPE_CLASS then return 'class'
    when Event::EVENT_TYPE_TOURNAMENT then return 'tournament'
    when Event::EVENT_TYPE_SEMINAR then return 'seminar'
    when Event::EVENT_TYPE_CAMP then return 'camp'
    end
  end
end
