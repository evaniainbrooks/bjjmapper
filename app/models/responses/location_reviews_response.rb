module Responses
  class LocationReviewsResponse
    attr_accessor :location_id
    attr_accessor :review_count
    attr_accessor :reviews
    attr_accessor :rating
    attr_accessor :summary
    attr_accessor :stars
    attr_accessor :half_star

    def initialize(attributes)
      attributes.each_pair do |k,v|
        raise ArgumentError, "Unknown key #{k}" unless self.respond_to?("#{k}=")
        self.send("#{k}=", v)
      end
    end
  end
end
