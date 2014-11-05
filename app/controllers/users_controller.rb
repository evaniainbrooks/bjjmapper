class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]
  decorates_assigned :user
  
  helper_method :welcome?

  def show
    respond_to do |format|
      format.json { render json: @user }
      format.html
    end
  end

  def create
    @user = User.create(create_params)
    respond_to do |format|
      format.json { render json: @user }
      format.html { redirect_to user_path(@user, edit: 1) }
    end
  end

  def update
    @user.update!(create_params)
    respond_to do |format|
      format.json { render json: @user }
      format.html { redirect_to user_path(@user, edit: 0) }
    end
  end

  private

  def welcome?
    params.fetch(:welcome, 0).to_i.eql?(1)
  end

  def create_params
    params.require(:user).permit(:name, :image, :email, :belt_rank, :stripe_rank, :birth_day, :birth_month, :birth_year, :lineal_parent, :birth_place, :description)
  end

  def set_user
    @user = User.find(params[:id])
    render status: :not_found and return unless @user.present?
  end
end
