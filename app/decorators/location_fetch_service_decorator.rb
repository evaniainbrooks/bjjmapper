class LocationFetchServiceDecorator < LocationDecorator
  delegate_all
  decorates :location

  def google_url
    "http://google.com/places/#{place_id}" if place_id
  end

  def yelp_url
    "http://yelp.com/biz/#{yelp_id}" if yelp_id
  end

  def health
    health_components = [yelp_url, google_url, facebook, twitter, instagram, team_id, website, email, phone]
    health_val = ((health_components.compact.size / health_components.size.to_f) * 100).to_i
  end

  def health_next_step_title
    "Write a review?"
  end

  def health_next_step_path
    h.location_path(location, anchor: 'reviews')
  end

  def website
    super_val = super
    if super_val.blank?
      service_data[:website]
    else
      super_val
    end
  end
  
  def phone
    super_val = super
    if super_val.blank?
      service_data[:phone]
    else
      super_val
    end
  end
  
  def email
    super_val = super
    if super_val.blank?
      service_data[:email]
    else
      super_val
    end
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
    end.with_indifferent_access
  end
end
