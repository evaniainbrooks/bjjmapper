class EventsController < ApplicationController
  before_action :set_location

  def index
    start_param = params.fetch(:start, nil)
    head :bad_request and return false unless start_param.present?
    start_param = DateTime.parse(start_param)

    end_param = params.fetch(:end, nil)
    head :bad_request and return false unless end_param.present?
    end_param = DateTime.parse(end_param)

    @events = @location.events.between_time(start_param, end_param)

    status = @events.count == 0 ? :no_content : :ok
    respond_to do |format|
      format.json { render status: status, json: @events }
    end
  end

  def show
    @event = @location.events.find(params[:id])
    respond_to do |format|
      format.json { render status: :ok, json: @event }
    end
  end

  def destroy
    respond_to do |format|
      format.json { render status: :ok, json: {} }
    end
  end

  def update
    respond_to do |format|
      format.json { render status: :ok, json: {} }
    end
  end

private

  def set_location
    @location = Location.find(params[:location_id])
    head :bad_request and return false unless @location.present?
  end
end
