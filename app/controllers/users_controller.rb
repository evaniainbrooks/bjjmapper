class UsersController < ApplicationController
  before_action :set_user, only: [:reviews, :show, :update]
  before_action :check_permissions, only: [:update]

  decorates_assigned :user

  helper_method :created?
  helper_method :welcome?
  helper_method :own_profile?

  REVIEW_COUNT_DEFAULT = 5
  REVIEW_COUNT_MAX = 50

  def index
    @users = User.jitsukas.where(:role.ne => 'anonymous').asc(:name).all.group_by(&:belt_rank)

    tracker.track('showUsersIndex')

    respond_to do |format|
      format.html
    end
  end

  def reviews
    count = [params.fetch(:count, REVIEW_COUNT_DEFAULT).to_i, REVIEW_COUNT_MAX].min

    tracker.track('showUserReviews',
      count: count
    )

    @reviews = @user.reviews.desc('created_at').limit(count)
    respond_to do |format|
      format.json { render json: ReviewDecorator.decorate_collection(@reviews) }
    end
  end

  def show
    tracker.track('showUser',
      id: @user.to_param
    )

    respond_to do |format|
      format.json { render json: @user }
      format.html
    end
  end

  def create
    @user = User.create(create_params)

    tracker.track('createUser',
      user: @user.as_json({})
    )

    respond_to do |format|
      format.json { render json: @user }
      format.html { redirect_to user_path(@user, edit: 1, create: 1) }
    end
  end

  def update
    tracker.track('updateUser',
      id: @user.to_param,
      user: @user.as_json({}),
      updates: create_params
    )

    @user.update!(create_params)

    respond_to do |format|
      format.json { render json: @user }
      format.html { redirect_to user_path(@user, edit: 0) }
    end
  end

  private

  def check_permissions
    head :forbidden and return false unless current_user.can_edit?(@user)
  end

  def welcome?
    params.fetch(:welcome, 0).to_i.eql?(1)
  end

  def created?
    return params.fetch(:create, 0).to_i.eql?(1)
  end

  def create_params
    p = params.require(:user).permit(:name, :image, :email, :belt_rank, :stripe_rank, :birth_day, :birth_month, :birth_year, :lineal_parent_id, :birth_place, :description, :female)
    p[:modifier_id] = current_user.to_param if signed_in?
    p
  end

  def set_user
    @user = User.find(params[:id])
    render status: :not_found and return unless @user.present?
  end

  def own_profile?
    return false unless defined?(@user)

    return @user.id.eql?(current_user.id)
  end
end
