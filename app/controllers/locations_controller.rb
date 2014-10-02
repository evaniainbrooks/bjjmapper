class LocationsController < ApplicationController
  before_filter :set_instructor, only: [:instructors]
  before_filter :set_location, only: [:show, :instructors]
  before_filter :set_map, only: :show
  helper_method :edit_mode?

  decorates_assigned :location

  def instructors
    @location.instructors << @instructor
    respond_to do |format|
      format.json { render json: @location }
      format.html { redirect_to location_path(@location, edit: 0) }
    end
  end

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
      format.json { render status: :ok, json: {} } 
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
    location = Location.create(create_params)
    location_json = location.to_json
    location.destroy
    respond_to do |format|
      format.json { render json: location_json }
      format.html { redirect_to root_path }
    end
  end

  def update
    location = Location.find(params[:id]).tap do |location|
      location.update!(create_params)
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

    head :bad_request and return unless center.is_a?(Array) && center.present? 

    locations = Location.near(center, distance).limit(50)
    locations = locations.where(:team_id => { '$in' => team }) if team.present?
    locations

    head :no_content and return unless locations.present?

    respond_to do |format|
      format.json { render json: locations.decorate }
    end
  end

  def index
    @criteria = params.slice(:city, :country) || {}
    @locations = @criteria.present? ? Location.where(@critieria).all : []
    
    respond_to do |format|
      format.html
      format.json { render json: @locations }
    end
  end

  private

  def set_instructor
    @instructor = User.find(params[:instructor_id]) if params.has_key?(:instructor_id)
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

  def edit_mode?
    params.fetch(:edit, 0).to_i.eql? 1
  end

  def create_params
    p = params.require(:location).permit(:city, :street, :postal_code, :state, :country, :title, :description, :coordinates, :team_id, :directions, :phone, :email)
    p[:coordinates] = JSON.parse(p[:coordinates]) if p.has_key?(:coordinates)
    p
  end
  
  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
