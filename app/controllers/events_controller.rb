class EventsController < ApplicationController
  before_action :set_location, except: [:omnischedule]
  before_action :set_locations, only: [:omnischedule]
  
  before_action :set_event, only: [:show, :destroy, :update, :move]
  before_action :validate_time_range, only: [:index, :omnischedule]
  
  before_action :ensure_signed_in, only: [:destroy, :create, :update]
  decorates_assigned :location, :locations, :event, :events

  around_filter :set_location_tz

  def create
    @event = Event.new(create_params)
    @location.events << @event

    status = @event.valid? ? :ok : :bad_request
    respond_to do |format|
      format.json { render status: status, json: event }
    end
  end

  def index
    @events = @location.schedule.events_between_time(@start_param, @end_param)

    status = @events.count == 0 ? :no_content : :ok
    respond_to do |format|
      format.json { render status: status, json: events }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render status: :ok, json: @event }
    end
  end

  def destroy
    @event = @location.events.find(params[:id])
    @event.destroy

    tracker.track('deleteEvent',
      event: @event.to_param
    )
    
    respond_to do |format|
      format.json { render status: :ok, json: {} }
      format.html { redirect_to schedule_location_path(location, edit: 1) }
    end
  end

  def move
    delta_seconds = params.fetch(:deltams, 0).to_i / 1000
    
    tracker.track('moveEvent',
      delta_seconds: delta_seconds,
      starting: @event.starting,
      ending: @event.ending,
      event: @event.to_param
    )

    @event.update_attributes({
      starting: @event.starting + delta_seconds.seconds,
      ending: @event.ending + delta_seconds.seconds
    })

    respond_to do |format|
      format.json { render status: :ok, json: @event }
    end
  end

  def update
    tracker.track('updateEvent',
      event: @event.to_param,
      params: create_params
    )

    @event.update(create_params)
    respond_to do |format|
      format.json { render status: :ok, json: {} }
      format.html { redirect_to location_event_path(location, @event, success: 1, edit: 0) }
    end
  end

  def omnischedule
    @events = []

    @locations.each do |location|
      @events.concat(location.schedule.events_between_time(@start_param, @end_param))
    end
    
    tracker.track('showOmniSchedule',
      location_count: @locations.count,
      event_count: @events.count
    )

    status = @events.count == 0 ? :no_content : :ok
    respond_to do |format|
      format.json { render status: status, json: events }
    end
  end

private
  def validate_time_range
    start_param = params.fetch(:start, nil)
    head :bad_request and return false unless start_param.present?
    @start_param = DateTime.parse(start_param).to_time

    end_param = params.fetch(:end, nil)
    head :bad_request and return false unless end_param.present?
    @end_param = DateTime.parse(end_param).to_time
  end
  
  def set_location_tz(&block)
    tz = (defined?(@location) ? @location.timezone : @locations.first.timezone) || 'UTC'
    Time.use_zone(tz, &block)
  end

  def create_params
    p = params.require(:event).permit(:starting, :ending, :event_recurrence, :title, :description, :instructor, :location, :weekly_recurrence_days => [])
    p[:modifier_id] = current_user.to_param if signed_in?
    p[:starting] = Time.zone.parse(p[:starting]) if p.key?(:starting)
    p[:ending] = Time.zone.parse(p[:ending]) if p.key?(:ending)
    p
  end

  def set_event
    @event = @location.events.where(id: params[:id]).first
    head :not_found and return false unless @event.present?
  end

  def set_locations
    @locations = Location.find(params[:ids])
    head :bad_request and return false unless @locations.present?
  end

  def set_location
    id_param = params.fetch(:location_id, '')
    @location = Location.find(id_param)
    head :bad_request and return false unless @location.present?
  end
end
