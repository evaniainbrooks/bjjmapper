class LocationFetchServiceDecorator < LocationDecorator
  delegate_all
  decorates :location

  PHOTO_COUNT = 50
  ALTERNATIVE_TITLE_MATCH_PERCENT = 90.0

  def updated_at
    val = profiles.values.collect{|p| p[:updated_at]}.push(object.updated_at).compact.max || 0
    "#{h.time_ago_in_words(val)} ago"
  end
  
  def jiujitsucom_url
    jiujitsucom_profile.try(:[], :url)
  end
  
  def foursquare_url
    foursquare_profile.try(:[], :url)
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
    health_components = [jiujitsucom_url, foursquare_url, facebook_url, yelp_url, google_url, facebook, twitter, instagram, team_id, website, email, phone]
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
    location.cover_image || cover_photo.try(:[], :url)
  end

  def cover_image_x
    if location.cover_image
      location.cover_image_x
    else
      cover_photo.try(:[], :offset_x)
    end
  end

  def cover_image_y
    if location.cover_image
      location.cover_image_y
    else
      cover_photo.try(:[], :offset_y)
    end
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

  def profile_match(profile)
    if profiles[profile].present?
      profiles[profile].try(:[], :address_match).try(:round, 1)
    end || 100.0
  end

  def profile_address(profile)
    addr = profiles[profile]
    addr.slice(:street, :city, :state, :postal_code, :country).values.compact.join(', ') if addr.present?
  end

  def photos
    photos_data.to_a
  end

  def profiles
    object_profiles = object.profiles.keys.inject({}) do |h, k|
      h[k] = { url: object.profiles[k] } if object.profiles[k].present?
      h
    end

    {
      jiujitsucom: jiujitsucom_profile,
      foursquare: foursquare_profile,
      google: google_profile,
      yelp: yelp_profile,
      facebook: facebook_profile
    }.merge(object_profiles).delete_if {|k, v| v.blank? }
  end

  def alternate_titles
    profiles.values.select {|p| (p[:title_match] || 100.0) < ALTERNATIVE_TITLE_MATCH_PERCENT }
  end

  def alternate_titles_tooltip
    header = "Alternate names: #{}"
    titles = alternate_titles.collect do |p|
      "\"#{p[:title]}\""
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
  
  def jiujitsucom_profile
    service_data_arr.find {|profile| profile[:source] == 'Jiujitsucom'}
  end
  
  def foursquare_profile
    service_data_arr.find {|profile| profile[:source] == 'Foursquare'}
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

      params = { lat: object.lat, lng: object.lng, title: object.title }.merge(self.address_components)
      RollFindr::LocationFetchService.listings(self.id, params)
    end || [])
  end

  def website_status_data
    @_response ||= RollFindr::Redis.cache(key: ['WebsiteStatus', self.id].join('-'), expire: 1.hour.seconds) do
      RollFindr::WebsiteStatusService.status(url: website, location_id: self.id.to_s)
    end
  end
end
