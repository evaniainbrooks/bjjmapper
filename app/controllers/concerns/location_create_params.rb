module LocationCreateParams
  extend ActiveSupport::Concern

  def location_create_params
    p = params.require(:location).permit(*Location::CREATE_PARAMS_WHITELIST, :coordinates => [])

    if p[:coordinates].present? && p[:coordinates].instance_of?(String)
      p[:coordinates] = JSON.parse(p[:coordinates])
    end

    p[:modifier] = current_user if signed_in?
    p
  end
end
