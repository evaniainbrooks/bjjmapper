class LocationFetchServiceDecorator < LocationDecorator
  delegate_all
  decorates :location

  PHOTO_COUNT = 50

  def updated_at
    val = profiles.collect{|p| p[:created_at]}.push(object.updated_at).compact.max
    "#{h.time_ago_in_words(val)} ago"
  end

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

  def cover_image
    cover_photo.try(:[], :url)    
  end

  def cover_image_offset_x
    cover_photo.try(:[], :offset_x)
  end

  def cover_image_offset_y
    cover_photo.try(:[], :offset_y)
  end

  def image_height
    100
  end

  def image_width
    100
  end

  def image
    if object.image.present?
      super
    else
      profile_photo.try(:[], :url) || super
    end
  end
  
  def image_tiny
    if object.image_tiny.present?
      super
    else
      profile_photo.try(:[], :url) || super
    end
  end
  
  def image_large
    if object.image_large.present?
      super
    else
      profile_photo.try(:[], :url) || super
    end
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
    r = website_status_data
    if r.nil? || r[:code].to_i == 0
      h.content_tag(:span, class: 'text-muted small') { '(unknown)' }
    else
      txtclass = r[:status] == 'available' ? 'small text-success' : 'small text-danger'
      h.content_tag(:span, class: txtclass) { "(#{r[:status]})" }
    end
  end
  
  def contact_info?
    phone.present? || email.present? || website.present? || facebook.present? || twitter.present? || instagram.present?
  end
  
  def yelp_match
    if yelp_address.present?
      yelp_profile.try(:[], :address_match).try(:round, 1)
    end
  end
  
  def yelp_address
    addr = yelp_profile 
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end

  def google_match
    if google_address.present?
      google_profile.try(:[], :address_match).try(:round, 1)
    end
  end
  
  def google_address
    addr = google_profile 
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end
  
  def facebook_match
    if facebook_address.present?
      facebook_profile.try(:[], :address_match).try(:round, 1)
    end
  end
  
  def facebook_address
    addr = facebook_profile
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end

  def photos
    photos_data.to_a
  end

  def profiles
    [google_profile, yelp_profile, facebook_profile].compact || []
  end

  def alternate_titles
    profiles.collect do |profile|
      profile[:title] if profile && (profile[:title_match] || 0) < 95.0
    end.compact.uniq
  end

  def alternate_titles_tooltip
    header = "Alternate names: #{}"
    titles = alternate_titles.collect do |title|
      "\"#{title}\""
    end.join("<br/>")

    [header, titles].join("<br/>").html_safe
  end

  def fan_count
    facebook_profile.try(:[], :fan_count)
  end

  def checkins
    facebook_profile.try(:[], :checkins)
  end

  def rating_count
    facebook_profile.try(:[], :rating_count)
  end

  def street
    object.street || source_address_component(:street)
  end
  
  def city
    object.city || source_address_component(:city)
  end
  
  def state
    object.state || source_address_component(:state)
  end

  def postal_code
    object.postal_code || source_address_component(:postal_code)
  end

  def country
    object.country || source_address_component(:country)
  end

  private

  def source_address_component(component)
    @_source_profile ||= service_data_arr.find {|profile| profile[:source] == object.source}
    return nil unless @_source_profile.present?

    @_source_profile[component]
  end

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

  def cover_photo
    photos_data.find {|o| o[:is_cover_photo] }
  end

  def profile_photo
    photos_data.find {|o| o[:is_profile_photo] && true != o[:is_silhouette] }
  end
  
  def photos_data
    @_photos_data ||= (RollFindr::Redis.cache(key: ['Photos', self.id, PHOTO_COUNT].join('-'), expire: 1.hour.seconds) do
      RollFindr::LocationFetchService.photos(self.id, count: PHOTO_COUNT)
    end || [])
  end

  def service_data(sym)
    service_data_arr.find { |profile| profile[sym] }.try(:[], sym)
  end

  def service_data_arr
    @_service_data ||= (RollFindr::Redis.cache(key: ['Detail', self.id].join('-'), expire: 1.hour.seconds) do
      RollFindr::LocationFetchService.detail(self.id, self.address_components.merge(title: object.title))
    end || [])
  end
  
  def website_status_data
    @_response ||= RollFindr::Redis.cache(key: ['WebsiteStatus', self.id].join('-'), expire: 1.hour.seconds) do
      RollFindr::WebsiteStatusService.status(url: website, location_id: self.id.to_s)
    end
  end
end
