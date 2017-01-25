class LocationFetchServiceDecorator < LocationDecorator
  delegate_all
  decorates :location

  ALTERNATE_TITLE_DISTANCE = 3

  def facebook_url
    facebook_profile.try(:[], :url)
  end

  def google_url
    google_profile.try(:[], :url)
  end

  def yelp_url
    yelp_profile.try(:[], :url)
  end

  def health
    health_components = [facebook_url, yelp_url, google_url, facebook, twitter, instagram, team_id, website, email, phone]
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

  def image
    profile_photo || super
  end

  def description
    if object.description.blank?
      facebook_profile.try(:[], :description) || facebook_profile.try(:[], :about) || super
    else
      object.description
    end
  end

  def facebook
    if object.facebook.blank?
      (facebook_url || "").strip.gsub!(Canonicalized::FACEBOOK_PATTERN, '')
    else
      object.facebook
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
    if yelp_address.present?
      dist = yelp_profile.try(:[], :address_levenshtein_distance)
      pct = (dist.to_f / [object.address.length, yelp_address.length].max) * 100.0
      (100.0 - pct).round(2)
    end
  end
  
  def yelp_address
    addr = yelp_profile 
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end

  def google_error
    if google_address.present?
      dist = google_profile.try(:[], :address_levenshtein_distance)
      pct = (dist.to_f / [object.address.length, google_address.length].max) * 100.0
      (100.0 - pct).round(2)
    end
  end
  
  def google_address
    addr = google_profile 
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end
  
  def facebook_error
    if facebook_address.present?
      dist = google_profile.try(:[], :address_levenshtein_distance)
      pct = (dist.to_f / [object.address.length, facebook_address.length].max) * 100.0
      (100.0 - pct).round(2)
    end
  end
  
  def facebook_address
    addr = facebook_profile 
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end

  def photos
    photos_data.to_a
  end

  def alternate_titles
    [google_profile, yelp_profile, facebook_profile].collect do |profile|
      profile[:title] if profile && (profile[:title_levenshtein_distance] || 0) >= ALTERNATE_TITLE_DISTANCE
    end.compact.uniq
  end

  def alternate_titles_tooltip
    header = "Alternate names: #{}"
    titles = alternate_titles.collect do |title|
      "\"#{title}\""
    end.join("<br/>")

    [header, titles].join("<br/>").html_safe
  end

  private

  def yelp_id
    yelp_profile.try(:[], :yelp_id)
  end

  def google_id
    google_profile.try(:[], :google_id)
  end

  def facebook_id
    facebook_profile.try(:[], :facebook_id)
  end

  def yelp_profile
    service_data_arr.find {|profile| profile[:source] == 'Yelp'}
  end

  def google_profile
    service_data_arr.find {|profile| profile[:source] == 'Google'}
  end

  def facebook_profile
    service_data_arr.find {|profile| profile[:source] == 'Facebook'}
  end

  def profile_photo
    photos_data.find {|o| o[:is_profile_photo] }.try(:[], :url)
  end
  
  def photos_data
    @_photos_data ||= (RollFindr::LocationFetchService.photos(self.id) || [])
  end

  def service_data(sym)
    service_data_arr.find { |profile| profile[sym] }.try(:[], sym)
  end

  def service_data_arr
    @_service_data ||= (RollFindr::LocationFetchService.detail(self.id, self.address_components.merge(title: object.title)) || [])
  end
end
