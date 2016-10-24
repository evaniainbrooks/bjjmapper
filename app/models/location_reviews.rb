class LocationReviews
  include Enumerable

  def initialize(location_id)
    @location_id = location_id.to_s

    initialize_reviews
  end

  def items
    return @_reviews
  end

  def rating
    return @_rating
  end

  def summary
    return @_review_summary
  end

  def each(&block)
    @_reviews.each(&block)
  end

  private

  def initialize_reviews
    local_reviews = Review.where(:location_id => @location_id)
    service_response = ::RollFindr::LocationFetchService.reviews(@location_id)

    service_reviews = service_response[:reviews].map do |r|
      service_review_to_local(r)
    end if service_response.present? && service_response[:reviews].present?

    @_reviews = [].concat(local_reviews).concat(service_reviews || []).sort_by(&:created_at).reverse
    @_review_summary = service_response.try(:[], :review_summary)
    @_rating = calculate_rating(local_reviews, service_response)
  end

  def calculate_rating(local_reviews, service_response)
    local_rating = begin
      local_reviews.inject(0.0) do |sum, r|
        sum = sum + r.rating.to_f
      end
    end if local_reviews.size > 0
    service_rating = service_response.try(:[], :rating)

    return 0.0 if local_rating.blank? && service_rating.blank?

    components = [local_rating, service_rating].compact
    components.inject(&:+) / components.size
  end

  def service_review_to_local(review)
    Review.new.tap do |r|
      r.body = review[:text]
      r.created_at = review[:time]
      r.location_id = @location_id
      r.author_link = review[:author_url]
      r.author_name = review[:author_name]
      r.rating = review[:rating] || 0.0
      r.src = review[:source]
    end
  end
end
