class TeamDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  INDEPENDENT = 'Independent'

  delegate_all
  decorates_finders
  decorates_association :locations
  decorates_association :parent_team
  decorates_association :child_teams

  def name
    if INDEPENDENT.eql? object.name
      object.name
    else
      "Team #{object.name}"
    end
  end

  # TODO: DRY up these methods
  def image_large
    img = object.image_large
    img = parent_team.image_large if img.blank? && parent_team.present?
    img = avatar_service_url(object.name, 300) if img.blank?
    h.image_path(img)
  end

  def image
    img = object.image
    img = parent_team.image if img.blank? && parent_team.present?
    img = avatar_service_url(object.name, 100) if img.blank?
    h.image_path(img)
  end

  def image_tiny
    img = object.image_tiny
    img = parent_team.image_tiny if img.blank? && parent_team.present?
    img = avatar_service_url(object.name, 50) if img.blank?
    h.image_path(img)
  end

  def updated_at
    object.updated_at.present? ? "updated #{h.time_ago_in_words(object.updated_at)} ago" : nil
  end

  def created_at
    object.created_at.present? ? "created #{h.time_ago_in_words(object.created_at)} ago" : nil
  end

  def description?
    object.description.present?
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

  private

  def avatar_service_url(name, size)
    "/service/avatar/#{size}x#{size}/#{CGI.escape(name)}/image.png"
  end
end
