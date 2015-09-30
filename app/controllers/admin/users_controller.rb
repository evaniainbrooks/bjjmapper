class Admin::UsersController < Admin::AdminController
  before_action :set_user
  
  def edit_merge
  end
  
  def merge
    tracker.track('mergeUser',
      src_id: @user.to_param,
      dst_id: current_user.to_param
    )

    merge_params = {
      :location_ids => current_user.location_ids.concat(@user.location_ids),
      :team_ids => current_user.team_ids.concat(@user.team_ids),
      :favorite_location_ids => current_user.favorite_location_ids.concat(@user.favorite_location_ids)
    }.merge(create_params)

    puts merge_params.inspect

    current_user.update!(merge_params)
    @user.update!({
      :redirect_to_user => current_user,
      :provider => nil,
      :location_ids => [],
      :favorite_location_ids => [],
      :team_ids => [],
      :oauth_token => nil,
      :role => 'stub'
    })

    redirect_to user_path(current_user, merge: 1)
  end

  private
  
  def create_params
    p = params.require(:user).permit(
      :name,
      :email,
      :image,
      :image_tiny,
      :image_large,
      :belt_rank,
      :stripe_rank,
      :birth_day,
      :birth_month,
      :birth_year,
      :lineal_parent_id,
      :birth_place,
      :description,
      :female,
      :flag_display_email,
      :flag_display_directory,
      :flag_display_reviews,
      :flag_locked)

    p[:modifier] = current_user if signed_in?
    p
  end

  def set_user
    @user = User.unscoped.find(params[:id])
    render status: :not_found and return unless @user.present?
  end
end

