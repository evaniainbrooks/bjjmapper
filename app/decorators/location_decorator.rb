class LocationDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :head_instructor

  decorates :location

  def description
    object.description || h.content_tag(:i) { 'No description was provided' }
  end

  def directions
    object.directions || h.content_tag(:i) { 'No extra directions were provided' }
  end

  def image
    object.image || 'academy-default-100.jpg'
  end

  def updated_at
    'updated ' + h.time_ago_in_words(object.updated_at) + ' ago'
  end

  def created_at
    'created ' + h.time_ago_in_words(object.created_at) + ' ago'
  end

  def team_name
    object.team_name.present? ? "Team #{object.team_name}" : "Independent"
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
