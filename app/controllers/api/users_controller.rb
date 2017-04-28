class Api::UsersController < Api::ApiController
  include Api::UserCreateParams
  
  before_action :set_user, only: [:update]

  def update
    @user.update!(api_user_create_params)

    respond_to do |format|
      format.json { render partial: 'users/user' }
    end
  end

  private

  def set_user
    @user = User.unscoped.find(params[:id])
    head :not_found and return false unless @user.present?
  end
end
