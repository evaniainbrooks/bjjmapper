class TeamDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :locations

  def name
    "Team #{object.name}"
  end

  def image
    h.path_to_asset(object.image, {type: :image})
  end
end
