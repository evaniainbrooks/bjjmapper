module Api
  module LocationCreateParams
    extend ActiveSupport::Concern

    CREATE_PARAMS_WHITELIST = [:image, :image_tiny, :image_large, :cover_image, :cover_image_x, :cover_image_y].freeze

    def api_location_create_params
      whitelist = [].concat(CREATE_PARAMS_WHITELIST).concat(::LocationCreateParams::CREATE_PARAMS_WHITELIST)
      p = params.require(:location).permit(*whitelist, :coordinates => [])

      if p[:coordinates].present? && p[:coordinates].instance_of?(String)
        p[:coordinates] = JSON.parse(p[:coordinates])
      end

      p[:modifier] = current_user if signed_in?
      p
    end
  end
end
