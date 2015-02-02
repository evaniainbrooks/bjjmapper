class LocationsController < ApplicationController
  before_action :set_directory_segments, only: [:index]
  before_action :set_location, only: [:schedule, :destroy, :show, :update, :nearby]
  before_action :set_map, only: :show
  before_action :ensure_signed_in, only: [:wizard, :destroy, :create, :update]
  decorates_assigned :location, :locations

  helper_method :created?
  helper_method :reviewed?
  helper_method :error?

  def schedule
    tracker.track('showSchedule',
      id: @location.to_param
    )

    respond_to do |format|
      format.html
    end
  end

  def show
    tracker.track('showLocation',
      id: @location.to_param
    )

    respond_to do |format|
      format.html
      format.json { render json: @location }
    end
  end

  def nearby
    distance = params.fetch(:distance, 5).to_i
    count = params.fetch(:count, 4).to_i

    @nearby_locations = Location.near(@location.to_coordinates, distance).limit(count+1).to_a
    @nearby_locations.reject!{|loc| loc.to_param.eql?(@location.to_param)}

    head :no_content and return false unless @nearby_locations.present?

    @nearby_locations = decorated_locations_with_distance_to_center(@nearby_locations, @location.to_coordinates)

    respond_to do |format|
      format.json { render status: :ok, json: @nearby_locations }
    end
  end

  def destroy
    tracker.track('deleteLocation',
      id: @location.to_param,
      location: @location.as_json({})
    )

    @location.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render status: :ok, json: @location }
    end
  end

  def wizard

  end

  def create
    location = Location.create(create_params)

    tracker.track('createLocation',
      location: location.as_json({})
    )

    respond_to do |format|
      format.json { render json: location }
      format.html { redirect_to location_path(location, edit: 1, create: 1) }
    end
  end

  def update
    tracker.track('updateLocation',
      id: @location.to_param,
      location: @location.as_json({}),
      updates: create_params
    )

    @location.update!(create_params)

    respond_to do |format|
      format.json { render json: @location }
      format.html { redirect_to location_path(location, edit: 0) }
    end
  end

  def search
    center = params.fetch(:center, nil)
    team = params.fetch(:team, nil)
    distance = params.fetch(:distance, 5.0)

    text_filter = params.fetch(:query, nil)
    filter_ids = Location.search_ids(text_filter).try(:to_set) if text_filter.present?

    head :bad_request and return unless center.is_a?(Array) && center.present?

    @locations = Location.near(center, distance)
    @locations = @locations.where(:team_id.in => team) if team.present?
    @locations = @locations.to_a

    if text_filter.present?
      @locations.select! do |location|
        filter_ids.include?(location.id.to_s)
      end
    end

    tracker.track('searchLocations',
      center: center,
      team: team,
      distance: distance,
      text_filter: text_filter,
      filter_ids: filter_ids.try(:count),
      results: @locations.count
    )

    head :no_content and return unless @locations.present?

    @locations = decorated_locations_with_distance_to_center(@locations, center)
    respond_to do |format|
      format.json { render json: @locations }
    end
  end

  def index
    @criteria = params.slice(:city, :country) || {}
    if @criteria.key?(:city) && @criteria.key?(:country)
      @locations = Location.near(@criteria.values.join(','), 30).decorate
    elsif @criteria.key?(:country)
      country_abbrev = @countries[ @criteria[:country] ]
      @locations = Location.where(:country.in => [@criteria[:country], country_abbrev]).decorate
    else
      @locations = []
    end

    tracker.track('showLocationsIndex',
      city: @criteria[:city],
      country: @criteria[:country],
      count: @locations.count,
    )

    @map = {
      :zoom => Map::ZOOM_CITY,
      :center => @locations.first.to_coordinates,
      :geolocate => 0,
      :locations => [],
      :refresh => 0
    } if @locations.present?

    respond_to do |format|
      format.html
      format.json { render json: locations }
    end
  end


  private

  def decorated_locations_with_distance_to_center(locations, center)
    LocationDecorator.decorate_collection(locations, context: { center: center })
  end

  private

  def created?
    return params.fetch(:create, 0).to_i.eql?(1)
  end
  
  def reviewed?
    return params.fetch(:reviewed, 0).to_i.eql?(1)
  end
  
  def error?
    return params.fetch(:error, 0).to_i.eql?(1)
  end

  def set_map
    @map = {
      :zoom => Map::ZOOM_LOCATION,
      :center => @location.to_coordinates,
      :geolocate => 0,
      :locations => [],
      :refresh => 0
    }
  end

  def create_params
    p = params.require(:location).permit(
      :city,
      :street,
      :postal_code,
      :state,
      :country,
      :title,
      :description,
      :coordinates,
      :team_id,
      :directions,
      :phone,
      :email,
      :website,
      :facebook)

    p[:coordinates] = JSON.parse(p[:coordinates]) if p[:coordinates].present?
    p[:modifier_id] = current_user.to_param if signed_in?
    p
  end

  def set_location
    id_param = params.fetch(:id, '').split('-', 2).first
    @location = Location.find(id_param)

    render status: :not_found and return unless @location.present?
  end

  def set_directory_segments
    # TODO: Refactor this out
    @countries = RollFindr::DirectoryCountries
    @cities = RollFindr::DirectoryCities
  end
end
