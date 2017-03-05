class ModerationNotificationDecorator < Draper::Decorator
  decorates :moderation_notification
  delegate_all

  def type
    object.type
  end
  
  def location
    @_location ||= begin
                     loc = Location.find(object.info[:location_id])
                     LocationFetchServiceDecorator.decorate(loc)
                   end
  end

  def duplicate_location
    @_duplicate_location ||= begin
                               loc = Location.find(object.info[:duplicate_location_id])
                               LocationFetchServiceDecorator.decorate(loc)
                             end
  end
end
