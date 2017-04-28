module UserCreateParams
  extend ActiveSupport::Concern
  
  CREATE_PARAMS_WHITELIST = [
    :name,
    :nickname,
    :cover_image,
    :contact_email,
    :belt_rank,
    :stripe_rank,
    :birth_day,
    :birth_month,
    :birth_year,
    :lineal_parent_id,
    :birth_place,
    :description,
    :female,
    :thumbnailx,
    :thumbnaily,
    :flag_display_email,
    :flag_display_directory,
    :flag_display_reviews,
    :flag_locked
  ].freeze

  def user_create_params
    p = params.require(:user).permit(*CREATE_PARAMS_WHITELIST)
    p[:modifier] = current_user if signed_in?
    p
  end
end
