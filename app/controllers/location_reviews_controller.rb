class LocationReviewsController < ApplicationController
  DEFAULT_REVIEW_COUNT = 50

  before_action :set_location
  before_action :ensure_signed_in, only: [:create]

  decorates_assigned :review, :location

  def index
    @offset = params.fetch(:offset, 0).try(:to_i)
    @limit = params.fetch(:count, DEFAULT_REVIEW_COUNT).try(:to_i)
  
    @reviews = @location.all_reviews.drop(@offset).take(@limit)

    head :no_content and return false unless @reviews.count > 0

    @response = Responses::LocationReviewsResponse.new({
      location_id: @location.id.to_s,
      review_count: @location.all_reviews.items.size,
      reviews: ReviewDecorator.decorate_collection(@reviews),
      rating: @location.rating,
      stars: @location.stars,
      half_star: @location.half_star?
    })
      
    respond_to do |format|
      format.json
    end
  end

  def create
    @review = Review.new(create_params)
    @location.reviews << @review
    respond_to do |format|
      format.json do
        status = @review.valid? ? :ok : :bad_request
        render status: status, partial: 'location_reviews/review'
      end
      format.html do
        error = @review.valid? ? 0 : 1
        redirect_to(location_path(@location, reviewed: 1, error: error))
      end
    end
  end

  private

  def create_params
    p = params.require(:review).permit(:body, :rating)
    p[:user] = current_user if signed_in?
    p[:rating] = p[:rating].to_i if p.key?(:rating)
    p
  end

  def set_location
    id_param = params.fetch(:location_id, '')
    @location = Location.find(id_param)

    render status: :not_found and return unless @location.present?
  end
end
