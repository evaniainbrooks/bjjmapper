class LocationFetchServiceDecorator < LocationDecorator
  delegate_all
  decorates :location

  def google_url
    place_url
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
    if object.website.present? && object.website.length > 3
      object.website
    else
      (service_data[:website] || "").strip.gsub!(Canonicalized::WEBSITE_PATTERN, '')
    end
  end
  
  def phone
    if object.phone.blank?
      service_data[:phone]
    else
      object.phone
    end
  end
  
  def email
    if object.email.blank? 
      service_data[:email]
    else
      object.email
    end
  end
  
  def website_status
    @_response ||= begin
      r = RollFindr::WebsiteStatusService.status(url: website, location_id: object.id.to_s)
      if r[:code].to_i == 0
        h.content_tag(:span, class: 'text-muted small') { '(unknown)' }
      else
        txtclass = r[:status] == 'available' ? 'small text-success' : 'small text-danger'
        h.content_tag(:span, class: txtclass) { "(#{r[:status]})" }
      end
    end
  end
  
  def contact_info?
    phone.present? || email.present? || website.present? || facebook.present? || twitter.present? || instagram.present?
  end

  private

  def place_url
    service_data[:place_url]
  end

  def yelp_id
    service_data[:yelp_id]
  end

  def place_id
    service_data[:place_id]
  end

  def service_data
    @_service_data ||= (RollFindr::LocationFetchService.detail(self.id.to_s) || {}).inject({}) do |hash, prefs|
      hash.merge(prefs)
    end.symbolize_keys
  end
end
