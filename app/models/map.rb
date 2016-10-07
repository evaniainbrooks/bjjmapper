class Map
  ZOOM_DEFAULT = 12
  ZOOM_LOCATION = 15
  ZOOM_CITY = 9
  ZOOM_HOMEPAGE = 7

  DEFAULT_MIN_ZOOM = 6
  GLOBAL_MIN_ZOOM = 4

  attr_accessor :lat, :lng
  attr_accessor :zoom, :query
  attr_accessor :location, :query
  attr_accessor :minZoom, :geolocate
  attr_accessor :locations, :refresh, :legend
  attr_accessor :event_type, :location_type

  def initialize(options = {})
    @zoom = options.fetch(:zoom, ZOOM_DEFAULT)
    @minZoom = options.fetch(:minZoom, DEFAULT_MIN_ZOOM)
    @geolocate = options.fetch(:geolocate, 1)
    @locations = options.fetch(:locations, [])
    @refresh = options.fetch(:refresh, 0)
    @legend = options.fetch(:legend, 0)
    @lat = options.fetch(:lat, nil)
    @lng = options.fetch(:lng, nil)
    @location = options.fetch(:location, nil)
    @query = options.fetch(:query, nil)
    @location_type = options.fetch(:location_type, [])
    @event_type = options.fetch(:event_type, [])
  end

  def [](index)
    instance_variable_get("@#{index}")
  end

  def model_name
    'map'
  end
end
