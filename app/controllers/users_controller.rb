class UsersController < ApplicationController
  before_action :set_user, only: [:destroy, :show, :update, :remove_image]
  before_action :redirect_legacy_bsonid, only: [:destroy, :show, :update, :remove_image]
  before_action :ensure_signed_in, only: [:update, :create, :remove_image]
  before_action :check_permissions, only: [:destroy, :update, :remove_image]

  decorates_assigned :user, :users 

  helper_method :created?
  helper_method :welcome?
  helper_method :own_profile?

  REVIEW_COUNT_DEFAULT = 5
  REVIEW_COUNT_MAX = 50

  def index
    @rank = params.fetch(:rank, nil)
    @query = params.fetch(:query, nil)
    @scope = @rank.present? ? User.where(belt_rank: @rank) : User.jitsukas

    @users = @scope
      .where(:flag_display_directory => true)
      .where(:role.ne => 'anonymous')
      .asc(:name)

    if @query.present?
      filter_ids = User.search_ids(@query) || []
      @users = @users.where(:_id.in => filter_ids)
    end

    tracker.track('showUsersIndex')

    respond_to do |format|
      format.json { render json: @users.collect{ |o| { id: o.id.to_s, name: [o.name, o.nickname].compact.join(', ') } } }
      format.html
    end
  end

  def show
    tracker.track('showUser',
      id: @user.to_param
    )

    respond_to do |format|
      format.json do
        if @user.redirect_to_user.present?
          @user = @user.redirect_to_user
        end
        render partial: 'users/user'
      end
      format.html do
        if @user.redirect_to_user.present?
          redirect_to user_path(@user.redirect_to_user)
        else
          render
        end
      end
    end
  end

  def create
    @user = User.create(create_params)

    tracker.track('createUser',
      user: @user.attributes.as_json({}),
      valid: @user.valid?
    )

    respond_to do |format|
      format.json { render partial: 'users/user' }
      format.html { redirect_to user_path(@user, edit: 1, create: 1) }
    end
  end

  def update
    tracker.track('updateUser',
      id: @user.to_param,
      user: @user.attributes.as_json({}),
      updates: create_params
    )

    @user.update!(create_params)

    respond_to do |format|
      format.json { render partial: 'users/user' }
      format.html { redirect_to user_path(@user, edit: 0) }
    end
  end

  def destroy
    tracker.track('deleteUser',
      id: @user.to_param,
      user: @user.attributes.as_json({})
    )

    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_path }
      format.json { render partial: 'users/user' }
    end
  end

  def remove_image
    tracker.track('removeUserImage',
      id: @user.to_param,
      image: @user.image
    )

    @user.update!({
      :image => nil,
      :image_large => nil,
      :image_tiny => nil
    })

    respond_to do |format|
      format.json { render partial: 'users/user' }
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
    p = params.require(:user).permit(
      :name,
      :email,
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
      :flag_locked)

    p[:modifier] = current_user if signed_in?
    p
  end

  def redirect_legacy_bsonid
    redirect_legacy_bsonid_for(@user, params[:id])
  end

  def set_user
    @user = User.unscoped.find(params[:id])
    head :not_found and return false unless @user.present?
  end

  def own_profile?
    return false unless defined?(@user)

    return @user.id.eql?(current_user.id)
  end
end
