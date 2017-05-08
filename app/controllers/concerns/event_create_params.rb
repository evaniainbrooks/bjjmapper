module EventCreateParams
  extend ActiveSupport::Concern
  
  CREATE_PARAMS_WHITELIST = [
    :event_type,
    :organization,
    :organization_id,
    :cover_image,
    :cover_image_x,
    :cover_image_y,
    :image,
    :image_large,
    :image_tiny,
    :starting,
    :ending,
    :event_recurrence,
    :title,
    :description,
    :instructor_id,
    :instructor,
    :location_id,
    :location,
    :parent_event_id,
    :email,
    :website,
    :facebook,
    :weekly_recurrence_days => []].freeze

  def event_create_params
    p = params.require(:event).permit(*CREATE_PARAMS_WHITELIST)
    p[:modifier] = current_user if signed_in?
    p[:starting] = Time.zone.parse(p[:starting]) if p.key?(:starting)
    p[:ending] = Time.zone.parse(p[:ending]) if p.key?(:ending)
    p
  end
end
