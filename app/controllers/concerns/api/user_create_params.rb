module Api
  module UserCreateParams
    extend ActiveSupport::Concern
    
    CREATE_PARAMS_WHITELIST = [
      :image,
      :image_large,
      :image_tiny
    ].freeze

    def api_user_create_params
      whitelist = [].concat(CREATE_PARAMS_WHITELIST).concat(::UserCreateParams::CREATE_PARAMS_WHITELIST)
      p = params.require(:user).permit(*whitelist)
      p[:modifier] = current_user if signed_in?
      p
    end
  end
end
