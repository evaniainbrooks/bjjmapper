class MapsController < ApplicationController
  DEFAULT_SEARCH_DISTANCE = 10.0
  DEFAULT_SEARCH_COUNT = 100

  DEFAULT_EVENT_START_OFFSET = 15.days
  DEFAULT_EVENT_END_OFFSET = 1.year

  before_filter :set_coordinates, only: [:show, :search]
  before_filter :set_locations_scope, only: [:show, :search]
  before_filter :filter_locations, only: [:show, :search]
  before_filter :set_coordinates_from_locations, only: [:show, :search]
  before_filter :validate_coordinates, only: [:search]
  before_filter :validate_event_time_range, only: [:search]
  around_filter :set_timezone, only: [:search]

  helper_method :map

  def show
    @location_type = params.fetch(:location_type, [Location::LOCATION_TYPE_ACADEMY]).collect(&:to_i)
    @event_type = params.fetch(:event_type, [Event::EVENT_TYPE_TOURNAMENT]).collect(&:to_i)

    tracker.track('showMap',
      zoom: map.zoom,
      lat: map.lat,
      lng: map.lng,
      query: map.query,
      geoquery: map.geoquery,
      geolocate: map.geolocate,
      event_type: map.event_type,
      location_type: map.location_type
    )

    respond_to do |format|
      format.html { render layout: 'map' }
    end
  end

  def search
    @event_type = params.fetch(:event_type, []).collect(&:to_i)
    @location_type = params.fetch(:location_type, []).collect(&:to_i)

    location_filter = @location_type.dup
    location_filter << Location::LOCATION_TYPE_EVENT_VENUE if @event_type.present?

    @events = Event.between_time(
      @event_start,
      @event_end)
    .where(
      :location_id.in => @locations.collect(&:id),
      :event_type.in => @event_type)
    @event_count = @events.count
    @events = @events.group_by(&:location_id)

    @locations = @locations.select do |location|
      has_events = @events[location.id].present?
      is_event_venue = has_events && Location::LOCATION_TYPE_ACADEMY == location.loctype
      is_empty_event_venue = !has_events && Location::LOCATION_TYPE_EVENT_VENUE == location.loctype

      (location_filter.include?(location.loctype) || is_event_venue) && !is_empty_event_venue
    end

    tracker.track('searchMap',
      lat: @lat,
      lng: @lng,
      team: @team,
      distance: @distance,
      query: @text_filter,
      location_type: location_filter,
      event_type: @event_type,
      event_start: @event_start,
      event_end: @event_end,
      results: @locations.count
    )

    @locations = decorated_locations(@locations, events: @events, lat: @lat, lng: @lng, event_type: @event_type, location_type: location_filter)

    respond_to do |format|
      format.json
    end
  end

  private

  def set_coordinates
    @geocode_query = params.fetch(:geoquery, nil)
    if @geocode_query.present?
      results = GeocodersHelper.search(@geocode_query)
      @lat = results.first.try(:lat)
      @lng = results.first.try(:lng)
    else
      @lat = params.fetch(:lat, nil).try(:to_f)
      @lng = params.fetch(:lng, nil).try(:to_f)
    end
  end

  def set_locations_scope
    @count = params.fetch(:count, DEFAULT_SEARCH_COUNT).to_i
    @text_filter = params.fetch(:query, nil)
    @distance = params.fetch(:distance, DEFAULT_SEARCH_DISTANCE).to_f
    @locations = if @lat.present? && @lng.present?
      Location.near([@lat, @lng], @distance).not_closed.not_pending.limit(@count)
      #Location.where(:coordinates => { "$within" => { "$center" => [[@lat, @lng], @distance ]}})
    elsif @text_filter.present?
      Location.not_closed.not_pending.limit(@count)
    end
  end

  def filter_locations
    if @text_filter.present? && @locations.present?
      filter_ids = Location.search_ids(@text_filter)
      @locations = @locations.where(:_id.in => filter_ids) if filter_ids.present?
    end

    @team = params.fetch(:team, [])
    @locations = @locations.where(:team_id.in => @team) if @team.present?
  end

  def set_coordinates_from_locations
    if (@lat.blank? || @lng.blank?) && @locations.present?
      @lat = @locations.first.lat
      @lng = @locations.first.lng
    end
  end

  def validate_coordinates
    head :bad_request and return false unless @lat.present? && @lng.present?
  end

  def validate_event_time_range
    start_param = params.fetch(:event_start, Time.now - DEFAULT_EVENT_START_OFFSET).try(:to_s)
    head :bad_request and return false unless start_param.present?
    @event_start = DateTime.parse(start_param).to_time

    end_param = params.fetch(:event_end, Time.now + DEFAULT_EVENT_END_OFFSET).try(:to_s)
    head :bad_request and return false unless end_param.present?
    @event_end = DateTime.parse(end_param).to_time
  end

  def set_timezone(&block)
    tz = RollFindr::TimezoneService.timezone_for(@lat, @lng) rescue nil
    Time.use_zone(tz, &block)
  end

  def decorated_locations(locations, context)
    MapLocationDecorator.decorate_collection(locations, context: context)
  end

  def map
    geolocate = @lat.blank? || @lng.blank? ? 1 : 0

    default_zoom = @lat.present? && @lng.present? ? Map::ZOOM_LOCATION : Map::ZOOM_DEFAULT
    zoom = params.fetch(:zoom, default_zoom).to_i

    @_map ||= Map.new(
      location_count: @locations.try(:count),
      event_count: @event_count,
      zoom: zoom,
      team: @team,
      lat: @lat,
      lng: @lng,
      query: @text_filter,
      geoquery: @geocode_query,
      minZoom: Map::DEFAULT_MIN_ZOOM,
      geolocate: geolocate,
      locations: action?(:search) ? @locations : [],
      refresh: 1,
      legend: 1,
      location_type: @location_type,
      event_type: @event_type
    )
  end
end

