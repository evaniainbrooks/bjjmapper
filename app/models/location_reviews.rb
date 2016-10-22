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

    @_reviews = [].concat(local_reviews).concat(service_reviews || [])
    @_rating = service_response.try(:[], :rating)
    @_review_summary = service_response.try(:[], :review_summary)
  end

  def service_review_to_local(review)
    Review.new.tap do |r|  
      r.body = review[:text]
      r.created_at = review[:time]
      r.location_id = @location_id
      r.user = User.new(id: review[:author_url], name: review[:author_name])
      r.user_link = review[:author_url]
      r.rating = review[:rating] || 5
    end
  end
end 
