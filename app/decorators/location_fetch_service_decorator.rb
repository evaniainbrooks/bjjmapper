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

  def website
    if object.website.present? && object.website.length > 3
      object.website
    else
      (service_data(:website) || "").strip.gsub!(Canonicalized::WEBSITE_PATTERN, '')
    end
  end
  
  def phone
    if object.phone.blank?
      service_data(:phone)
    else
      object.phone
    end
  end
  
  def email
    if object.email.blank? 
      service_data(:email)
    else
      object.email
    end
  end
  
  def website_status
    @_response ||= begin
      r = RollFindr::WebsiteStatusService.status(url: website, location_id: object.id.to_s)
      if r.nil? || r[:code].to_i == 0
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
  
  def yelp_error
    dist = service_data_arr.find {|profile| profile[:source] == 'Yelp'}.try(:[], :levenshtein_distance)
    if yelp_address.present?
      pct = (dist.to_f / [object.address.length, yelp_address.length].max) * 100.0
      (100.0 - pct).round(2)
    end
  end
  
  def yelp_address
    addr = service_data_arr.find {|profile| profile[:source] == 'Yelp'}
    addr.slice(:street, :city, :country, :state, :postal_code).values.join(', ') if addr.present?
  end

  def google_error
    dist = service_data_arr.find {|profile| profile[:source] == 'Google'}.try(:[], :levenshtein_distance)
    if google_address.present?
      pct = (dist.to_f / [object.address.length, google_address.length].max) * 100.0
      (100.0 - pct).round(2)
    end
  end
  
  def google_address
    addr = service_data_arr.find {|profile| profile[:source] == 'Google'}
    addr.slice(:street, :city, :country, :state, :postal_code).values.join(', ') if addr.present?
  end

  def photos
    photos_data.collect{|x| x[:large_url]}
  end

  def small_photos
    photos_data.collect{|x| x[:url].gsub(/w500/, 'w100') }
  end

  private

  def place_url
    service_data(:place_url)
  end

  def yelp_id
    service_data(:yelp_id)
  end

  def place_id
    service_data(:place_id)
  end
  
  def photos_data
    @_photos_data ||= (RollFindr::LocationFetchService.photos(self.id) || [])
  end

  def service_data(sym)
    service_data_arr.find { |profile| profile[sym] }.try(:[], sym)
  end

  def service_data_arr
    @_service_data ||= (RollFindr::LocationFetchService.detail(self.id, self.address_components) || [])
  end
end
