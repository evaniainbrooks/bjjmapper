class LocationDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  DEFAULT_DIRECTIONS = 'No extra directions were provided'
  DEFAULT_IMAGE = 'academy-default-100.jpg'
  DEFAULT_TEAM_NAME = 'Independent'

  delegate_all
  decorates_finders
  decorates_association :instructors
  decorates_association :team

  decorates :location

  attr_accessor :distance

  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i) { DEFAULT_DESCRIPTION }
    end
  end

  def directions
    if object.directions.present?
      object.directions
    else
      h.content_tag(:i) { DEFAULT_DIRECTIONS }
    end
  end

  def address
    object.address.split(',',2).join(h.tag(:br)).html_safe
  end

  def image
    img = object.image
    img = team.object.image if img.blank? && team.present?
    img = DEFAULT_IMAGE if img.blank?
    h.image_path(img)
  end

  def updated_at
    "updated #{h.time_ago_in_words(object.updated_at)} ago"
  end

  def created_at
    "created #{h.time_ago_in_words(object.created_at)} ago"
  end

  def team_name
    object.team_name.present? ? "Team #{object.team_name}" : DEFAULT_TEAM_NAME
  end

  def phone
    h.number_to_phone(object.phone)
  end

  def as_json(args)
    # Select which decorator methods override the defaults from object
    object.as_json(args).merge(
      image: image,
      address: address,
      team_name: team_name,
      created_at: created_at,
      updated_at: updated_at,
      distance: distance
    )
  end
end

