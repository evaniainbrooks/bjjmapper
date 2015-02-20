class TeamDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  
  delegate_all
  decorates_finders
  decorates_association :locations
  decorates_association :parent_team
  decorates_association :child_teams

  def name
    "Team #{object.name}"
  end

  def image
    h.image_path(object.image)
  end
  
  def updated_at
    object.updated_at.present? ? "updated #{h.time_ago_in_words(object.updated_at)} ago" : nil
  end

  def created_at
    object.created_at.present? ? "created #{h.time_ago_in_words(object.created_at)} ago" : nil
  end
  
  def description
    if object.description.present?
      object.description
    else
      h.content_tag(:i, class: 'text-muted') { DEFAULT_DESCRIPTION }
    end
  end

  def as_json(args)
    object.as_json(args).symbolize_keys.merge(
      image: image,
      created_at: created_at,
      updated_at: updated_at
    )
  end
end
