class ReviewsController < ApplicationController
  before_action :set_location

  def index
    @reviews = @location.reviews
    status = @reviews.blank? ? :no_content : :ok
    respond_to do |format|
      format.json { render status: status, json: @reviews }
    end
  end

  def create
    @review = Review.new(create_params)
    @location.reviews << @review
    status = @review.valid? ? :ok : :bad_request
    respond_to do |format|
      format.json { render status: status, json: @review }
    end
  end

  private

  def create_params
    p = params.require(:review).permit(:body, :rating)
    p[:user] = current_user if signed_in?
    p
  end

  def set_location
    id_param = params.fetch(:location_id, '').split('-', 2).first
    @location = Location.find(id_param)

    render status: :not_found and return unless @location.present?
  end
end
