class DirectorySegmentDecorator < Draper::Decorator
  delegate_all
  decorates_association :locations

  def zoom
    object.zoom || (object.child? ? Map::ZOOM_DEFAULT : Map::ZOOM_HOMEPAGE)
  end

  def segment_params
    if child?
      { city: object.to_param, country: object.parent_segment.to_param }
    else
      { country: object.to_param }
    end
  end

  def as_json(args)
    object.as_json(args).symbolize_keys.merge(
      zoom: zoom,
      segment_params: segment_params
    )
  end
end
