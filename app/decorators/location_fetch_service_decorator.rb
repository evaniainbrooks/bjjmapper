class LocationFetchServiceDecorator < LocationDecorator
  delegate_all
  decorates :location

  def google_url
    "http://google.com/places/#{place_id}" if place_id
  end

  def yelp_url
    "http://yelp.com/biz/#{yelp_id}" if yelp_id
  end

  private

  def yelp_id
    service_data[:yelp_id]
  end

  def place_id
    service_data[:place_id]
  end

  def service_data
    @_data ||= (RollFindr::LocationFetchService.detail(self.id.to_s) || {}).inject({}) do |hash, prefs|
      hash.merge(prefs)
    end
  end
end
