require 'event_schedule'

class LocationEventsController < ApplicationController
  include EventsHelper

  before_action :set_location

  before_action :set_event, only: [:show, :destroy, :update, :move]
  before_action :validate_time_range, only: [:index]

  before_action :set_map, only: [:show]

  before_action :ensure_signed_in, only: [:destroy, :create, :update]
  decorates_assigned :location, :event, :events

  around_filter :set_location_tz

  def create
    event = Event.new(event_create_params)
    @location.events << event
    
    tracker.track('createEvent',
      location: @location.to_param,
      event: @event.to_json({}),
      source: 'location_events'
    )

    respond_to do |format|
      format.json do
        if !event.valid?
          render status: :bad_request
        else
          @events = if event.recurring? && params.key?(:interval_start) && params.key?(:interval_end)
            interval_start = DateTime.parse(params[:interval_start]).to_time
            interval_end = DateTime.parse(params[:interval_end]).to_time

            RollFindr::EventSchedule.new(nil, [event]).events_between_time(interval_start, interval_end)
          else
            [event]
          end

          render
        end
      end
    end
  end

  def index
    @events = @location.schedule.events_between_time(@start_param, @end_param)

    respond_to do |format|
      format.json do
        if @events.count == 0
          render status: :no_content
        else
          render
        end
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json
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

    @event.starting = @event.starting + delta_seconds.seconds
    @event.ending = @event.ending + delta_seconds.seconds

    @event.schedule.start_time = @event.schedule.start_time + delta_seconds.seconds
    @event.save

    respond_to do |format|
      format.json { render partial: 'events/event' }
    end
  end

  def update
    tracker.track('updateEvent',
      event: @event.to_param,
      params: event_create_params
    )

    @event.update(event_create_params)
    respond_to do |format|
      format.json { render status: :ok, json: {} }
      format.html { redirect_to location_event_path(location, @event, success: 1, edit: 0) }
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
    tz = @location.timezone
    Time.use_zone(tz, &block)
  end

  def set_event
    @event = @location.events.find(params[:id])
    head :not_found and return false unless @event.present?
  end

  def set_location
    id_param = params.fetch(:location_id, '')
    @location = Location.includes(:events).find(id_param)
    head :bad_request and return false unless @location.present?
  end

  def set_map
    @map = Map.new(
      :zoom => Map::ZOOM_LOCATION,
      :minZoom => Map::ZOOM_CITY,
      :lat => @location.lat,
      :lng => @location.lng,
      :geolocate => 0,
      :locations => [],
      :location_type => Location::LOCATION_TYPE_ALL,
      :event_type => Event::EVENT_TYPE_ALL,
      :refresh => 0
    )
  end
end
