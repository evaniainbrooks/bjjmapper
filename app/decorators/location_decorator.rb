class LocationDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  DEFAULT_DIRECTIONS = 'No extra directions were provided'
  DEFAULT_IMAGE = 'https://storage.googleapis.com/bjjmapper/academy-default-100.png'
  DEFAULT_TEAM_NAME = 'Independent'

  EMPTY_HASH = {}.freeze

  OPEN_MAT_COLOR_ORDINAL = 999
  GUEST_INSTRUCTOR_COLOR_ORDINAL = 888

  delegate_all
  decorates_finders
  decorates_association :instructors
  decorates_association :team

  decorates :location

  def initialize(object, options = EMPTY_HASH)
    super(object, options)
    if (context.key?(:center))
      @distance = Geocoder::Calculations.distance_between(
        context[:center],
        object.to_coordinates
      )

      @bearing = Geocoder::Calculations.bearing_between(
        context[:center],
        object.to_coordinates,
        method: :linear
      )
    end
  end

  def instructor_color_ordinal(instructor)
    return OPEN_MAT_COLOR_ORDINAL unless instructor.present?
    self.instructors.index(instructor) || GUEST_INSTRUCTOR_COLOR_ORDINAL
  end

  def bearing_direction
    return nil unless bearing.present?

    @bearing_direction ||= if (bearing >= 337.5 || bearing < 22.5)
      :north
    elsif (bearing >= 22.5 && bearing < 67.5)
      :'north-east'
    elsif (bearing >= 67.5 && bearing < 112.5)
      :east
    elsif (bearing >= 112.5 && bearing < 157.5)
      :'south-east'
    elsif (bearing >= 157.5 && bearing < 202.5)
      :south
    elsif (bearing >= 202.5 && bearing < 247.5)
      :'south-west'
    elsif (bearing >= 247.5 && bearing < 292.5)
      :west
    else
      :'north-west'
    end
  end

  def bearing
    @bearing
  end

  def distance
    @distance.present? ? "#{h.number_with_precision(@distance, precision: 2)}mi" : nil
  end

  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i, class: 'text-muted') { DEFAULT_DESCRIPTION }
    end
  end

  def directions
    if object.directions.present?
      object.directions
    else
      h.content_tag(:i, class: 'text-muted') { DEFAULT_DIRECTIONS }
    end
  end

  def gps
    object.to_coordinates.map{|e| h.number_with_precision(e, precision: 4)}.join(", ")
  end

  def address
    object.address.split(',',2).join(h.tag(:br)).html_safe
  end

  def image
    img = object.image
    img = team.object.image if img.blank? && team.present?
    img = avatar_service_url(object.title) if img.blank?
    img = DEFAULT_IMAGE if img.blank?
    h.image_path(img)
  end

  def opengraph_image
    object.team.try(:image_large)
  end

  def opengraph_updated_at
    object.updated_at.to_i
  end

  def updated_at
    object.updated_at.present? ? "updated #{h.time_ago_in_words(object.updated_at)} ago" : nil
  end

  def created_at
    object.created_at.present? ? "created #{h.time_ago_in_words(object.created_at)} ago" : nil
  end

  def team_name
    object.team_name.present? ? "Team #{object.team_name}" : DEFAULT_TEAM_NAME
  end

  def phone
    h.number_to_phone(object.phone)
  end

  def contact_info?
    object.phone.present? || object.email.present? || object.website.present? || object.facebook.present?
  end

  def as_json(args)
    # Select which decorator methods override the defaults from object
    object.as_json(args).symbolize_keys.merge(
      image: image,
      #address: address,
      phone: phone,
      team_name: team_name,
      created_at: created_at,
      updated_at: updated_at,
      distance: distance,
      bearing: bearing,
      bearing_direction: bearing_direction,
      opengraph_updated_at: opengraph_updated_at,
      opengraph_image: opengraph_image
    )
  end

  private

  def avatar_service_url(name)
    "/service/avatar/100x100/#{CGI.escape(name)}/image.png"
  end
end

