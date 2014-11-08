class LocationsController < ApplicationController
  before_action :set_instructor, only: [:instructors]
  before_action :set_location, only: [:show, :instructors]
  before_action :set_map, only: :show

  decorates_assigned :location

  def show
    respond_to do |format|
      format.json { render json: @location }
      format.html
    end
  end

  def destroy
    location = Location.find(params[:id]).destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { render status: :ok, json: location }
    end
  end

  def create
    location = Location.create(create_params)
    respond_to do |format|
      format.json { render json: location }
      format.html { redirect_to location_path(location, edit: 1) }
    end
  end

  def geocode
    search_query = params.fetch(:query, '')
    search_result = Geocoder.search(search_query)

    respond_to do |format|
      format.json do
        if search_result.count > 0
          render json: search_result[0].geometry['location']
        else
          render status: :not_found, json: {}
        end
      end
    end
  end

  def update
    location = Location.find(params[:id]).tap do |loc|
      loc.update!(create_params)
    end
    respond_to do |format|
      format.json { render json: location }
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

    locations = Location.near(center, distance).limit(50)
    locations = locations.where(:team_id.in => team) if team.present?
    locations = locations.select do |location|
      filter_ids.include?(location.to_param)
    end if text_filter.present?

    head :no_content and return unless locations.present?

    respond_to do |format|
      format.json { render json: LocationDecorator.decorate_collection(locations.to_a) }
    end
  end

  def index
    @criteria = params.slice(:city, :country) || {}
    if @criteria.key?(:city) && @criteria.key?(:country)
      @locations = Location.near(@criteria.values.join(','), 30)
    elsif @criteria.key?(:country)
      @locations = Location.where(:country => @criteria[:country])
    else
      @locations = []
    end

    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end

  private

  def set_instructor
    @instructor = User.find(params[:instructor_id]) if params.key?(:instructor_id)
    head :not_found and return false unless @instructor.present?
  end

  def set_map
    @map = {
      :zoom => Map::ZOOM_LOCATION,
      :center => @location.to_coordinates,
      :geolocate => 0,
      :locations => [],
      :filters => 0
    }
  end

  def create_params
    p = params.require(:location).permit(:city, :street, :postal_code, :state, :country, :title, :description, :coordinates, :team_id, :directions, :phone, :email, :website)
    p[:coordinates] = JSON.parse(p[:coordinates]) if p.key?(:coordinates)
    p
  end

  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
