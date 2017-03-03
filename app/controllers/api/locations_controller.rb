class Api::LocationsController < Api::ApiController
  include LocationCreateParams

  DEFAULT_SEARCH_DISTANCE = 10.0
  DEFAULT_SEARCH_COUNT = 100

  before_filter :set_coordinates, only: [:index]
  before_filter :set_locations_scope, only: [:index]
  before_filter :filter_locations, only: [:index]

  helper_method :location

  def index
    respond_to do |format|
      format.json
    end
  end

  def create
    @location = Location.new(location_create_params)
    if @location.academy? && @location.team.nil?
      @location.team = guess_team(location_create_params[:title])
    end
    @location.save!

    respond_to do |format|
      format.json { render partial: 'locations/location' }
    end
  end
  
  def update
    id_param = params.fetch(:id, '')
    @location = Location.find(id_param)
    
    head :not_found and return false unless @location.present?

    @location.update!(location_create_params)

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

  def notifications
    ReportMailer.report_email(params[:message], 'Duplicate location', params.fetch(:extras, {}).inspect.to_s, current_user).deliver
    head :accepted
  end

  private

  def location
    @location
  end

  def guess_team(title)
     Team.all.select{|t| title.downcase.index(t.name.downcase) != nil}.first
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

    return unless @lat.present? && @lng.present?
    @locations = Location
      .limit(@count)
      .offset(@offset)
      .where(:coordinates => { "$geoWithin" => { "$centerSphere" => [[@lng, @lat], @distance/3963.2] }})

    @locations = @locations.not_closed unless flag?(:closed)
    @locations = @locations.not_rejected unless flag?(:rejected)
    @locations = @locations.verified unless flag?(:unverified) 
    @locations = @locations.with_black_belt if flag?(:bbonly)
    @locations = @locations.sort_by {|loc| Geocoder::Calculations.distance_between([@lat, @lng], loc.to_coordinates) }
    @locations
  end

  def filter_locations
    if @text_filter.present? && @locations.present?
      @locations = @locations.search(@text_filter)
    end

    @team = params.fetch(:team, [])
    @locations = @locations.where(:team_id.in => @team) if @team.present?
  end

  def set_timezone(&block)
    tz = RollFindr::TimezoneService.timezone_for(@lat, @lng) rescue nil
    Time.use_zone(tz, &block)
  end
end
