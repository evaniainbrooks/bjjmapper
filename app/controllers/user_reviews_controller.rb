class UserReviewsController < ApplicationController
  before_action :set_user
  before_action :redirect_legacy_bsonid

  decorates_assigned :user, :reviews

  REVIEW_COUNT_DEFAULT = 5
  REVIEW_COUNT_MAX = 50

  def index
    count = [params.fetch(:count, REVIEW_COUNT_DEFAULT).to_i, REVIEW_COUNT_MAX].min

    tracker.track('showUserReviews',
      count: count
    )

    @reviews = @user.reviews.desc('created_at').limit(count)
    respond_to do |format|
      format.json
    end
  end

  private

  def set_user
    @user = User.unscoped.find(params[:user_id])
    render status: :not_found and return unless @user.present?
  end

  def redirect_legacy_bsonid
    redirect_legacy_bsonid_for(@user, params[:user_id], user_reviews_path(@user))
  end
end
