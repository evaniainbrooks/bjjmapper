module EventCreateParams
  extend ActiveSupport::Concern

  def event_create_params
    p = params.require(:event).permit(*Event::CREATE_PARAMS_WHITELIST)
    p[:modifier] = current_user if signed_in?
    p[:starting] = Time.zone.parse(p[:starting]) if p.key?(:starting)
    p[:ending] = Time.zone.parse(p[:ending]) if p.key?(:ending)
    p
  end
end
