class MapsController < ApplicationController
  DEFAULT_SEARCH_DISTANCE = Map::DEFAULT_SEARCH_DISTANCE
  DEFAULT_SEARCH_COUNT = Map::DEFAULT_COUNT

  DEFAULT_SORT_ORDER = Map::DEFAULT_SORT_ORDER

  DEFAULT_EVENT_START_OFFSET = Map::DEFAULT_EVENT_START_OFFSET
  DEFAULT_EVENT_END_OFFSET = Map::DEFAULT_EVENT_END_OFFSET


  before_filter :validate_event_time_range, only: [:show, :search]
  before_filter :set_filters, only: [:show, :search]
  before_filter :set_segment, only: [:show, :search]
  before_filter :set_coordinates, only: [:show, :search]
  before_filter :set_locations_scope, only: [:show, :search]
  before_filter :filter_locations, only: [:show, :search]
  before_filter :set_coordinates_from_locations, only: [:show, :search]
  before_filter :validate_coordinates, only: [:search]
  around_filter :set_timezone, only: [:search]

  helper_method :map

  def show
    tracker.track('showMap',
      zoom: map.zoom,
      lat: map.lat,
      lng: map.lng,
      query: map.query,
      geoquery: map.geoquery,
      geolocate: map.geolocate,
      event_type: map.event_type,
      location_type: map.location_type,
      count: map.count,
      offset: map.offset,
      flags: flags
    )

    respond_to do |format|
      format.html { render layout: 'map' }
    end
  end

  def search
    @locations = @locations.try(:to_a)

    @events = Event.between_time(
      @event_start,
      @event_end)
    .where(
      :location_id.in => @locations.collect(&:id),
      :event_type.in => @event_type)

    @events = @events.where(:source.ne => 'import_bjjatlas_json.rb') if FeatureSetting.enabled?(:hide_bjjatlas_events)
    @events = @events.to_a

    @event_count = @events.count
    @events = @events.group_by(&:location_id)

    @locations = @locations.select do |location|
      has_events = @events[location.id].present?
      is_event_venue = has_events && Location::LOCATION_TYPE_ACADEMY == location.loctype
      is_empty_event_venue = !has_events && Location::LOCATION_TYPE_EVENT_VENUE == location.loctype

      !is_empty_event_venue
    end

    tracker.track('searchMap',
      lat: @lat,
      lng: @lng,
      team: @team,
      distance: @distance,
      query: @text_filter,
      location_type: @location_type,
      event_type: @event_type,
      event_start: @event_start,
      event_end: @event_end,
      results: @locations.count,
      count: @count,
      offset: @offset,
      sort: @sort,
      flags: flags
    )

    @locations = decorated_locations(@locations, events: @events, lat: @lat, lng: @lng, event_type: @event_type, location_type: @location_type)

    #TODO: Don't use the decorator in controller...
    @sort = params.fetch(:sort, DEFAULT_SORT_ORDER).to_sym
    @locations = case @sort
      when :distance
        @locations.sort_by {|loc| Geocoder::Calculations.distance_between([@lat, @lng], loc.to_coordinates) }
      when :rating
        @locations.sort_by {|loc| loc.rating }
      when :title
        @locations.sort_by {|loc| loc.title }
      when :newest
        @locations.sort_by {|loc| loc.object.created_at }
      when :oldest
        @locations.sort_by {|loc| -loc.object.created_at }
      else
        @locations
      end

    respond_to do |format|
      format.json
    end
  end

  private

  def flags
    Map::DEFAULT_FLAGS.keys.inject({}) do |hash, k|
      hash[k] = flag?(k) ? 1 : 0
      hash
    end
  end

  def flag?(f)
    params.fetch(f, 0).try(:to_i) == 1
  end

  def set_filters
    @event_type = params.fetch(:event_type, action?(:show) ? [Event::EVENT_TYPE_TOURNAMENT] : []).collect(&:to_i)
    @location_type = params.fetch(:location_type, action?(:show) ? [Location::LOCATION_TYPE_ACADEMY] : []).collect(&:to_i)
  end

  def set_segment
    id = params.fetch(:segment, nil)
    @segment = if id.is_a?(Array)
      criteria = { country: id.last }
      criteria.merge!(city: id.first) if id.length > 1
      DirectorySegment.for(criteria)
    else
      DirectorySegment.find(id) unless id.blank?
    end
  end

  def set_coordinates
    @geocode_query = params.fetch(:geoquery, nil)
    if @geocode_query.present?
      results = GeocodersHelper.search(@geocode_query)
      @lat = results.first.try(:lat)
      @lng = results.first.try(:lng)
    elsif @segment.present?
      @lat = @segment.lat
      @lng = @segment.lng
    else
      @lat = params.fetch(:lat, nil).try(:to_f)
      @lng = params.fetch(:lng, nil).try(:to_f)
    end
  end

  def set_locations_scope
    @count = params.fetch(:count, DEFAULT_SEARCH_COUNT).to_i
    @offset = params.fetch(:offset, 0).to_i
    @text_filter = params.fetch(:query, nil)
    @distance = params.fetch(:distance, DEFAULT_SEARCH_DISTANCE).to_f
   
    loctypes = @location_type.dup
    loctypes << Location::LOCATION_TYPE_EVENT_VENUE if @event_type.present?
    loctypes.uniq!

    if @segment.present?
      @locations = @segment.locations.where(:loctype.in => loctypes).limit(@count).offset(@offset)
    elsif @lat.present? && @lng.present?
      @locations = Location.where(:loctype.in => loctypes).limit(@count).offset(@offset).where(:coordinates => { "$geoWithin" => { "$centerSphere" => [[@lng, @lat], @distance/3963.2] }})
    elsif @text_filter.present?
      @locations = Location.where(:loctype.in => loctypes).limit(@count).offset(@offset)
    else
      return
    end
    
    @locations = @locations.where(:street.nin => ['', nil]) if FeatureSetting.enabled?(:hide_locations_with_missing_street)
    @locations = @locations.not_closed unless flag?(:closed)
    @locations = @locations.not_rejected unless flag?(:rejected)
    @locations = @locations.verified unless flag?(:unverified)
    @locations = @locations.with_black_belt if flag?(:bbonly)
    @locations
  end

  def filter_locations
    if @text_filter.present? && @locations.present?
      @locations = @locations.search(@text_filter)
    end

    @team = params.fetch(:team, [])
    @locations = @locations.where(:team_id.in => @team) if @team.present?
    @locations = @locations.to_a
  end

  def set_coordinates_from_locations
    return if @locations.blank?
    
    if (@lat.blank? || @lng.blank?) || @text_filter.present?
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
    @event_start = DateTime.parse(start_param).beginning_of_day.to_time

    end_param = params.fetch(:event_end, Time.now + DEFAULT_EVENT_END_OFFSET).try(:to_s)
    head :bad_request and return false unless end_param.present?
    @event_end = DateTime.parse(end_param).beginning_of_day.to_time
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

    default_zoom = Map::ZOOM_DEFAULT
    zoom = params.fetch(:zoom, default_zoom).to_i

    @_map ||= Map.new(
      location_count: @locations.try(:count),
      event_count: @event_count,
      event_start: @event_start,
      event_end: @event_end,
      zoom: zoom,
      team: @team,
      lat: @lat,
      lng: @lng,
      query: @text_filter,
      geoquery: @geocode_query,
      segment: @segment.try(:id).try(:to_s),
      minZoom: [Map::DEFAULT_MIN_ZOOM, zoom].min,
      geolocate: geolocate,
      locations: action?(:search) ? @locations : [],
      flags: flags,
      refresh: 1, #TODO: Move these flags to decorator
      legend: 1,
      location_type: @location_type,
      event_type: @event_type,
      count: @count,
      offset: @offset,
      sort: @sort
    )
  end
end

