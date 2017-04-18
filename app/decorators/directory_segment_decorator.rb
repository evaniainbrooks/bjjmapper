class DirectorySegmentDecorator < Draper::Decorator
  delegate_all

  def zoom
    object.zoom || (object.child? ? Map::ZOOM_DEFAULT : Map::ZOOM_HOMEPAGE)
  end

  def locations
    @_locations ||= LocationDecorator.decorate_collection(object.locations)
  end

  def notifications
    @_notifications ||= ModerationNotificationDecorator.decorate_collection(object.notifications)
  end

  def segment_params
    if child?
      { city: object.to_param, country: object.parent_segment.to_param }
    else
      { country: object.to_param }
    end
  end
end
