class TeamDecorator < Draper::Decorator
  DEFAULT_DESCRIPTION = 'No description was provided'
  INDEPENDENT = 'Independent'

  delegate_all
  decorates_finders
  decorates_association :locations
  decorates_association :parent_team
  decorates_association :child_teams

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
      h.content_tag(:i, class: 'text-muted') { generated_description }
    end
  end

  private

  def generated_description
    count = RollFindr::Redis.cache(key: ['TeamLocationCount', object.id.to_s].join('-'), expire: 1.day.seconds) do
      object.locations.count
    end

    countries = RollFindr::Redis.cache(key: ['TeamLocationCountryCount', object.id.to_s].join('-'), expire: 1.day.seconds) do
      object.locations.to_a.collect(&:country).uniq.count
    end

    "#{object.name} is a Brazilian Jiu-Jitsu association with #{h.pluralize(count, 'affiliated academy')}  in #{h.pluralize(countries, 'different country')}." +
    if object.instructors.present?
      if object.instructors.count > 1
        " #{object.instructors.collect(&:name).join(', ')} are the head instructors."
      else
        " #{object.instructors.first.name} is the founder and head instructor."
      end
    end || ''
  end

  def avatar_service_url(name, size)
    "/service/avatar/#{size}x#{size}/#{CGI.escape(name)}/image.png"
  end
end
