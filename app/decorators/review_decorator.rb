class ReviewDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :location
  decorates_association :user

  def as_json(args)
    object.as_json(args).merge(
      location_image: location.image
    )
  end
end
