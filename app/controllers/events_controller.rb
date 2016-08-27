class EventsController < ApplicationController
  before_action :set_locations, only: [:index]
  before_action :validate_time_range, only: [:index]

  around_filter :set_location_tz, only: [:index]

  decorates_assigned :events

  DEFAULT_SEARCH_DISTANCE = 5.0

  def wizard
  end

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

private
  def set_locations
    @locations = Location.includes(:events).find(params[:ids])
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

