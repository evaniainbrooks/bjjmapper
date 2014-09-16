class LocationsController < ApplicationController
  before_filter :set_location, only: :show
  
  decorates_assigned :location

  def show
    respond_to do |format|
      format.json { render json: @location }
      format.html 
    end
  end

  def create
    location = Location.create(create_params)
    respond_to do |format|
      format.json { render json: location }
      format.html { redirect_to location }
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
    Location.find(params[:id]).tap do |location|
      location.update!(create_params)
    end
    respond_to do |format|
      format.json { render json: location }
      format.html { redirect_to root_path }
    end
  end

  def search
    searchables = viewport_query
    render :no_content and return unless searchables.present?

    respond_to do |format|
      format.json { render json: searchables.decorate }
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

  def viewport_query
    # TODO Distance value
    center = params.fetch(:center, [])
    team = params.fetch(:team, nil)
   
    return nil unless center.present?

    # TODO Distance value
    locations = Location.near(center, 25).limit(50)
    locations = locations.where(:team_id => team) if team.present?
    locations
  end

  def create_params
    p = params.require(:location).permit(:title, :description, :coordinates, :team_id)
    p[:coordinates] = JSON.parse(p[:coordinates])
    p
  end
  
  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
