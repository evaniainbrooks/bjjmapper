class MapsController < ApplicationController
  DEFAULT_SEARCH_DISTANCE = 10.0

  before_filter :set_map, only: [:show]

  def show
    tracker.track('showMap',
      zoom: @map.zoom,
      lat: @map.lat,
      lng: @map.lng,
      query: @map.query,
      location: @map.location,
      geolocate: @map.geolocate,
      event_type: @map.event_type,
      location_type: @map.location_type
    )

    respond_to do |format|
      format.html { render layout: 'map' }
    end
  end

  def search
    lat = params.fetch(:lat, nil).try(:to_f)
    lng = params.fetch(:lng, nil).try(:to_f)
    team = params.fetch(:team, nil)
    distance = params.fetch(:distance, DEFAULT_SEARCH_DISTANCE).to_f
    text_filter = params.fetch(:query, nil)
    event_filter = params.fetch(:event_type, []).collect(&:to_i)

    location_filter = params.fetch(:location_type, []).collect(&:to_i)
    location_filter << Location::LOCATION_TYPE_EVENT_VENUE if event_filter.present?

    head :bad_request and return false unless lat.present? && lng.present? && distance.present?

    @locations = Location.near([lat, lng], distance)
    @locations = @locations.where(:team_id.in => team) if team.present?

    if text_filter.present?
      filter_ids = Location.search_ids(text_filter).try(:to_set) if text_filter.present?
      @locations = @locations.select do |location|
        filter_ids.include?(location.id.to_s)
      end
    end

    @events = Event.where(
      :location_id.in => @locations.collect(&:id),
      :event_type.in => event_filter).to_a

    @events = EventDecorator.decorate_collection(@events).group_by(&:location_id)

    @locations = @locations.select do |location|
      has_events = @events[location.id].present?
      is_event_venue = has_events && Location::LOCATION_TYPE_ACADEMY == location.loctype

      location_filter.include?(location.loctype) || is_event_venue
    end

    tracker.track('searchMap',
      lat: lat,
      lng: lng,
      team: team,
      distance: distance,
      query: text_filter,
      location_type: location_filter,
      event_type: event_filter,
      results: @locations.count
    )

    head :no_content and return unless @locations.present?

    @locations = decorated_locations_with_distance_to_center(@locations, lat, lng)

    respond_to do |format|
      format.json
    end
  end

  private

  def decorated_locations_with_distance_to_center(locations, lat, lng)
    LocationDecorator.decorate_collection(locations, context: { lat: lat, lng: lng })
  end

  def set_map
    lat = params.fetch(:lat, nil).try(:to_f)
    lng = params.fetch(:lng, nil).try(:to_f)
    query = params.fetch(:query, "")
    location = params.fetch(:location, "")
    geolocate = (lat.blank? && lng.blank?) && query.blank? && location.blank? ? 1 : 0

    default_zoom = lat.present? && lng.present? ? Map::ZOOM_LOCATION : Map::ZOOM_DEFAULT
    zoom = params.fetch(:zoom, default_zoom).to_i

    location_type = params.fetch(:location_type, [Location::LOCATION_TYPE_ACADEMY])
    event_type = params.fetch(:event_type, []).collect(&:to_i)

    @map = Map.new(
      zoom: zoom,
      lat: lat,
      lng: lng,
      query: query,
      location: location,
      minZoom: Map::DEFAULT_MIN_ZOOM,
      geolocate: geolocate,
      locations: [],
      refresh: 1,
      legend: 1,
      location_type: location_type,
      event_type: event_type
    )
  end
end

