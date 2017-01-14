class Map
  ZOOM_HOMEPAGE = 7
  ZOOM_CITY = 9
  ZOOM_LOCATION = 15
  ZOOM_DEFAULT = ZOOM_CITY

  DEFAULT_MIN_ZOOM = 5
  GLOBAL_MIN_ZOOM = 4

  DEFAULT_SORT_ORDER = :distance
  DEFAULT_FLAGS = { rejected: 0, closed: 0, bbonly: 0, unverified: 0 }.freeze
  DEFAULT_COUNT = 50
  DEFAULT_EVENT_START_OFFSET = 15.days
  DEFAULT_EVENT_END_OFFSET = 1.year
  DEFAULT_SEARCH_DISTANCE = 10.0

  attr_accessor :event_start, :event_end
  attr_accessor :count, :offset # for pagination
  attr_accessor :location_count, :event_count # results count
  attr_accessor :lat, :lng, :segment, :distance
  attr_accessor :zoom, :query
  attr_accessor :geoquery, :query
  attr_accessor :minZoom, :geolocate, :sort
  attr_accessor :locations, :refresh, :legend
  attr_accessor :event_type, :location_type, :team

  attr_accessor :flags

  def initialize(options = {})
    @zoom = options.fetch(:zoom, ZOOM_DEFAULT)
    @minZoom = options.fetch(:minZoom, DEFAULT_MIN_ZOOM)
    @distance = options.fetch(:distance, nil)
    @geolocate = options.fetch(:geolocate, 1)
    @locations = options.fetch(:locations, [])
    @refresh = options.fetch(:refresh, 0)
    @legend = options.fetch(:legend, 0)
    @lat = options.fetch(:lat, nil)
    @lng = options.fetch(:lng, nil)
    @geoquery = options.fetch(:geoquery, nil)
    @query = options.fetch(:query, nil)
    @team = options.fetch(:team, [])
    @location_type = options.fetch(:location_type, [])
    @event_type = options.fetch(:event_type, [])
    @location_count = options.fetch(:location_count, 0)
    @event_count = options.fetch(:event_count, 0)
    @count = options.fetch(:count, DEFAULT_COUNT)
    @offset = options.fetch(:offset, 0)
    @segment = options.fetch(:segment, nil)
    @event_start = options.fetch(:event_start, nil)
    @event_end = options.fetch(:event_end, nil)
    @sort = options.fetch(:sort, DEFAULT_SORT_ORDER)
    @flags = options.fetch(:flags, DEFAULT_FLAGS)
  end

  def [](index)
    instance_variable_get("@#{index}")
  end

  def as_json(args = {})
    raise StandardError, "Use a JBuilder template"
  end

  def model_name
    'map'
  end
end
