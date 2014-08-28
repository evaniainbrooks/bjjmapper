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

  def set_location
    @location = Location.find(params[:id])
    render status: :not_found and return unless @location.present?
  end
end
