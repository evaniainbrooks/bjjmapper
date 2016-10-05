module EventsHelper
  def event_type_name(event_type)
    case event_type
    when Event::EVENT_TYPE_CLASS then return 'class'
    when Event::EVENT_TYPE_TOURNAMENT then return 'tournament'
    when Event::EVENT_TYPE_SEMINAR then return 'seminar'
    when Event::EVENT_TYPE_CAMP then return 'camp'
    end
  end

  def event_create_params
    p = params.require(:event).permit(*Event::CREATE_PARAMS_WHITELIST)
    p[:modifier] = current_user if signed_in?
    p[:starting] = Time.zone.parse(p[:starting]) if p.key?(:starting)
    p[:ending] = Time.zone.parse(p[:ending]) if p.key?(:ending)
    p
  end
end
