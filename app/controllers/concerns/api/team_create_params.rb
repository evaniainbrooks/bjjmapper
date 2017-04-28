module Api
  module TeamCreateParams
    extend ActiveSupport::Concern
    
    CREATE_PARAMS_WHITELIST = [
      :image,
      :image_large,
      :image_tiny,
      :cover_image,
      :cover_image_x,
      :cover_image_y
    ].freeze

    def api_team_create_params
      whitelist = [].concat(CREATE_PARAMS_WHITELIST).concat(::TeamCreateParams::CREATE_PARAMS_WHITELIST)
      p = params.require(:team).permit(*whitelist)
      p[:modifier] = current_user if signed_in?
      p
    end
  end
end
