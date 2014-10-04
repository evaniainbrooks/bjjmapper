class InstructorsController < ApplicationController
  before_filter :set_location
  before_filter :set_instructor, only: [:destroy]

  def create
    @instructor = User.find(params[:id])
    @location.instructors << @instructor
    respond_to do |format|
      format.html { redirect_to location_path(@location, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  def destroy
    @location.instructors.delete(@instructor)
    respond_to do |format|
      format.html { redirect_to location_path(@location, edit: 1) }
      format.json { render :json => {}, :status => :ok }
    end
  end

  private

  def set_location
    @location = Location.find(params[:location_id])
    head :not_found and return false unless @location.present?
  end

  def set_instructor
    @instructor = @location.instructors.find(params[:id])
    head :not_found and return false  unless @instructor.present?
  end
end
