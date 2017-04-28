module TeamCreateParams
  extend ActiveSupport::Concern
  
  CREATE_PARAMS_WHITELIST = [
    :name,
    :description,
    :parent_team_id,
    :primary_color_index,
    :modifier_id,
    :ig_hashtag
  ].freeze

  def team_create_params
    p = params.require(:team).permit(*CREATE_PARAMS_WHITELIST)
    p[:modifier] = current_user if signed_in?
    p
  end
end
