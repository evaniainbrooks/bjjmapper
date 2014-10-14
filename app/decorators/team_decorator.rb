class TeamDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :locations

  def name
    "Team #{object.name}"
  end

  def image
    h.image_path(object.image)
  end
end
