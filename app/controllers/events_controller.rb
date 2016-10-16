class EventsController < ApplicationController
  include EventsHelper
  include LocationsHelper

  before_action :set_locations, only: [:index]
  before_action :validate_time_range, only: [:index]
  before_action :ensure_signed_in, only: [:create, :wizard]

  around_filter :set_location_tz, only: [:index]

  decorates_assigned :events, :event, :location

  DEFAULT_SEARCH_DISTANCE = 5.0
  DEFAULT_UPCOMING_EVENTS_COUNT = 7

  def create
    @location = find_or_create_location
    head :bad_request and return false unless @location.valid?

    Time.use_zone(@location.timezone) do
      @event = Event.create(event_create_params)
      @location.events << @event
      @redirect_path = location_event_path(@location, @event, create: 1)

      tracker.track('createEvent',
        location: @location.to_param,
        event: @event.to_json({}),
        source: 'events'
      )

      respond_to do |format|
        format.json
      end
    end
  end

  def wizard
    tracker.track('showEventVenueWizard')
    respond_to do |format|
      format.html
    end
  end

  #omnicalendar
  def index
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

  def upcoming
    count = params.fetch(:count, DEFAULT_UPCOMING_EVENTS_COUNT).to_i
    event_types = params.fetch(:event_type, Event::EVENT_TYPE_ALL).collect(&:to_i)
    event_types.delete(Event::EVENT_TYPE_CLASS)
    organization = params.fetch(:organization_id, nil)
    instructor = params.fetch(:instructor_id, nil)

    @events = Event
      .where(:event_type.in => event_types)
      .between_time(Time.now.beginning_of_day, Time.now + 1.year)
      .limit(count)
      .asc(:starting)

    @events = @events.where(:organization_id => organization) if organization.present?
    @events = @events.where(:instructor_id => instructor) if instructor.present?

    tracker.track('showUpcomingEvents',
      event_count: @events.count
    )

    respond_to do |format|
      format.json do
        render status: :no_content and return if @events.count == 0
        render
      end
    end
  end

private
  def find_or_create_location
    id = params.fetch(:location_id, nil)
    if id.present?
      Location.find(id)
    else
      Location.create!(location_create_params)
    end
  end

  def set_locations
    @locations = Location.find(params[:ids])
    head :bad_request and return false unless @locations.present?
  end

  def set_location_tz(&block)
    tz = (@locations.first.timezone) || 'UTC'
    Time.use_zone(tz, &block)
  end
  
  def validate_time_range
    start_param = params.fetch(:start, nil)
    head :bad_request and return false unless start_param.present?
    @start_param = DateTime.parse(start_param).to_time

    end_param = params.fetch(:end, nil)
    head :bad_request and return false unless end_param.present?
    @end_param = DateTime.parse(end_param).to_time
  end
end

