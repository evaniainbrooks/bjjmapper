class EventsController < ApplicationController
  before_action :set_location
  before_action :ensure_signed_in, only: [:destroy, :create, :update]
  decorates_assigned :event, :events

  def create
    @event = Event.new(create_params)
    @location.events << @event

    status = @event.valid? ? :ok : :bad_request
    respond_to do |format|
      format.json { render status: status, json: event }
    end
  end

  def index
    start_param = params.fetch(:start, nil)
    head :bad_request and return false unless start_param.present?
    start_param = DateTime.parse(start_param).to_time

    end_param = params.fetch(:end, nil)
    head :bad_request and return false unless end_param.present?
    end_param = DateTime.parse(end_param).to_time

    @events = @location.schedule.events_between_time(start_param, end_param)

    status = @events.count == 0 ? :no_content : :ok
    respond_to do |format|
      format.json { render status: status, json: events }
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

  def create_params
    p = params.require(:event).permit(:starting, :ending, :recurrence, :title, :description, :instructor, :location)
    p[:modifier_id] = current_user.to_param if signed_in?
    p
  end

  def set_location
    id_param = params.fetch(:location_id, '').split('-', 2).first
    @location = Location.find(id_param)
    head :bad_request and return false unless @location.present?
  end
end
