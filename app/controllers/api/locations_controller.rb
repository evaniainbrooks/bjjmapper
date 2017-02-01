class Api::LocationsController < Api::ApiController
  include LocationsHelper

  DEFAULT_SEARCH_DISTANCE = 10.0
  DEFAULT_SEARCH_COUNT = 100

  DEFAULT_SORT_ORDER = Map::DEFAULT_SORT_ORDER

  before_filter :set_coordinates, only: [:index]
  before_filter :set_locations_scope, only: [:index]
  before_filter :filter_locations, only: [:index]

  helper_method :location

  def index
    @sort = params.fetch(:sort, DEFAULT_SORT_ORDER).to_sym
    @locations = case @sort
      when :distance 
        @locations.sort_by {|loc| loc.instance_variable_get('@distance') }
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

  def create
    @location = Location.new(create_params)
    if @location.academy? && @location.team.nil?
      @location.team = guess_team(create_params[:title])
    end
    @location.save!

    respond_to do |format|
      format.json { render partial: 'locations/location' }
    end
  end
  
  def random
    scope = Location.academies.verified
    @location = scope.skip(rand(scope.count)).first

    respond_to do |format|
      format.json { render partial: 'locations/location' }
    end
  end

  private

  def location
    @location
  end

  def guess_team(title)
     Team.all.select{|t| title.downcase.index(t.name.downcase) != nil}.first
  end

  def create_params
    location_create_params
  end

  def flags
    Map::DEFAULT_FLAGS.keys.inject({}) do |hash, k|
      hash[k] = flag?(k) ? 1 : 0
      hash
    end
  end

  def flag?(f)
    params.fetch(f, 0).try(:to_i) == 1
  end

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
  
    head :bad_request and return false unless @lat.present? && @lng.present?
  end

  def set_locations_scope
    @count = params.fetch(:count, DEFAULT_SEARCH_COUNT).to_i
    @offset = params.fetch(:offset, 0).to_i
    @text_filter = params.fetch(:query, nil)
    @distance = params.fetch(:distance, DEFAULT_SEARCH_DISTANCE).to_f

    @locations = if @lat.present? && @lng.present?
      Location.near([@lat, @lng], @distance).limit(@count).offset(@offset)
    elsif @text_filter.present?
      Location.limit(@count).offset(@offset)
    end

    return unless @locations.present?

    @locations = @locations.not_closed unless flag?(:closed)
    @locations = @locations.not_rejected unless flag?(:rejected)
    @locations = @locations.verified unless flag?(:unverified) 
    @locations = @locations.with_black_belt if flag?(:bbonly)
    @locations
  end

  def filter_locations
    if @text_filter.present? && @locations.present?
      filter_ids = Location.search_ids(@text_filter)
      @locations = @locations.where(:_id.in => filter_ids) if filter_ids.present?
    end

    @team = params.fetch(:team, [])
    @locations = @locations.where(:team_id.in => @team) if @team.present?
  end

  def set_timezone(&block)
    tz = RollFindr::TimezoneService.timezone_for(@lat, @lng) rescue nil
    Time.use_zone(tz, &block)
  end
end
