class LocationsController < ApplicationController
  before_filter :set_location, only: :show

  def show
    respond_to do |format|
      format.json { render @location }
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
    searchables = if term_query?
      Location.all.to_a
    else
      viewport_query
    end
      
    respond_to do |format|
      format.json { render json: searchables }
    end
  end

  def index
  end

  private

  def viewport_query
    # TODO Distance value
    center = params[:center]
    locations = Location.near(center, 25)
  end

  def term_query?
    params[:q].present?
  end

  def create_params
    p = params.require(:location).permit(:title, :description, :coordinates)
    p[:coordinates] = JSON.parse(p[:coordinates])
    p
  end
  
  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
