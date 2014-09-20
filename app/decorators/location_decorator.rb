class LocationDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  DEFAULT_DIRECTIONS = 'No extra directions were provided'
  DEFAULT_IMAGE = 'academy-default-100.jpg'
  DEFAULT_TEAM_NAME = 'Independent'

  delegate_all
  decorates_finders
  decorates_association :instructors

  decorates :location

  def description
    object.description.present? ? object.description : h.content_tag(:i) { DEFAULT_DESCRIPTION }
  end

  def directions
    object.directions.present? ? object.directions :  h.content_tag(:i) { DEFAULT_DIRECTIONS }
  end

  def image
    (object.image.present? ? object.image : DEFAULT_IMAGE)
  end

  def updated_at
    'updated ' + h.time_ago_in_words(object.updated_at) + ' ago'
  end

  def created_at
    'created ' + h.time_ago_in_words(object.created_at) + ' ago'
  end

  def team_name
    object.team_name.present? ? "Team #{object.team_name}" : DEFAULT_TEAM_NAME
  end

  def phone
    h.number_to_phone(object.phone)
  end

  def as_json args
    # Select which decorator methods override the defaults from object
    object.as_json(args).merge({
      :image => image,
      :team_name => team_name,
      :created_at => created_at,
      :updated_at => updated_at
    })
  end
end

