require 'i18n'

class LocationDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  DEFAULT_TEAM_NAME = 'Independent'

  EMPTY_HASH = {}.freeze

  OPEN_MAT_COLOR_ORDINAL = 999
  GUEST_INSTRUCTOR_COLOR_ORDINAL = 888

  delegate_all
  decorates_finders
  decorates_association :instructors
  decorates_association :team
  decorates_association :events

  decorates :location

  def initialize(object, options = EMPTY_HASH)
    super(object, options)
    if (context.key?(:lat) && context.key?(:lng))
      @distance = Geocoder::Calculations.distance_between(
        [ context[:lat], context[:lng] ],
        object.to_coordinates
      )

      @bearing = Geocoder::Calculations.bearing_between(
        [ context[:lat], context[:lng] ],
        object.to_coordinates,
        method: :linear
      )
    end
  end

  def instructor_color_ordinal(instructor)
    return OPEN_MAT_COLOR_ORDINAL unless instructor.present?
    self.instructors.index(instructor) || GUEST_INSTRUCTOR_COLOR_ORDINAL
  end

  def seo_title
    if object.loctype == Location::LOCATION_TYPE_ACADEMY
      "#{object.title} #{"BJJ" unless object.title.end_with?("BJJ")} academy in #{object.city}, #{object.country}"
    else
      "#{object.title} BJJ event venue in #{object.city}, #{object.country}"
    end
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

  def distance_raw
    @distance
  end

  def distance
    @distance.present? ? "#{h.number_with_precision(@distance, precision: 2)}mi" : nil
  end

  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i, class: 'text-muted') { generated_description }
    end
  end

  def gps
    object.to_coordinates.map{|e| h.number_with_precision(e, precision: 4)}.join(", ")
  end

  def address
    h.format_address(object.address)
  end

  def image
    img = object.image
    img = team.image if img.blank? && team.present?
    img.present? ? h.image_path(img) : nil
  end

  def image_tiny
    img = object.image_tiny
    img = team.image_tiny if img.blank? && team.present?
    img.present? ? h.image_path(img) : nil
  end

  def image_large
    img = object.image_large
    img = team.image_large if img.blank? && team.present?
    img.present? ? h.image_path(img) : nil
  end

  def opengraph_image
    object.team.try(:image_large)
  end

  def opengraph_updated_at
    object.updated_at.to_i
  end

  def schedule_updated_at
    object.schedule_updated_at.present? ? "#{h.time_ago_in_words(object.schedule_updated_at)} ago" : 'never'
  end

  def updated_at
    object.updated_at.present? ? "#{h.time_ago_in_words(object.updated_at).gsub('about ', '')} ago" : nil
  end

  def created_at
    object.created_at.present? ? "#{h.time_ago_in_words(object.created_at).gsub('about ', '')} ago" : nil
  end

  def team_name
    object.team_name.present? ? object.team_name : DEFAULT_TEAM_NAME
  end

  def phone
    h.number_to_phone(object.phone) if object.phone
  end

  def facebook_group?
    !object.facebook.try(:index, 'groups').nil?
  end

  private

  def generated_description
    # TODO: Move this to string resources yml
    desc = if self.team.present?
      "'#{self.object.title}' is a #{self.object.team.name} affiliated Brazilian Jiu-Jitsu academy located at #{self.object.street} in #{self.object.city}, #{self.object.country}"
    else
      "'#{self.object.title}' is an independent Brazilian Jiu-Jitsu academy located at #{self.object.street} in #{self.object.city}, #{self.object.country}"
    end

    if self.instructors.present?
      instructors = self.instructors.collect do |instructor|
        h.link_to("#{instructor.name} (#{instructor.rank_in_words})", instructor)
      end

      instructor_desc = if instructors.length > 1
        "Instructors are #{instructors.join(', ')}"
      else
        "The instructor is #{instructors.first}"
      end

      desc = "#{desc}. #{instructor_desc}"
    end

    if self.object.email.present?
      desc = "#{desc}. Contact #{h.mail_to(self.object.email)} for more information."
    end

    desc.html_safe
  end
end

