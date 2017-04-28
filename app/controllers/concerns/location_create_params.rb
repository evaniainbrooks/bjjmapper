module LocationCreateParams
  extend ActiveSupport::Concern
  
  CREATE_PARAMS_WHITELIST = [
   :loctype,
    :ig_hashtag,
    :city,
    :street,
    :postal_code,
    :state,
    :country,
    :title,
    :description,
    :team_id,
    :directions,
    :phone,
    :email,
    :website,
    :source,
    :status,
    :status_updated_at,
    :facebook_id,
    :yelp_id,
    :google_id,
    :twitter,
    :flag_closed,
    :instagram,
    :coordinates => []].freeze

  def location_create_params
    p = params.require(:location).permit(*CREATE_PARAMS_WHITELIST)

    if p[:coordinates].present? && p[:coordinates].instance_of?(String)
      p[:coordinates] = JSON.parse(p[:coordinates])
    end

    p[:modifier] = current_user if signed_in?
    p
  end
end
