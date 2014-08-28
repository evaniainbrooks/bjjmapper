class LocationsController < ApplicationController
  before_filter :set_location, only: :show

  def show
    render @location 
  end

  def create
    @location = Location.new(params[:location])
    @location.save

    redirect_to root_path
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
  
  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
