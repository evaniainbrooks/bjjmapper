class ReviewDecorator < Draper::Decorator
  delegate_all
  decorates_finders
  decorates_association :location
  decorates_association :user
end
