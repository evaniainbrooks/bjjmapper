class Api::EventsController < Api::ApiController
  include ::EventCreateParams
  include ::LocationCreateParams
  
  def create
    @location = find_or_create_location
    head :bad_request and return false unless @location.valid?

    Time.use_zone(@location.timezone) do
      @event = Event.create(event_create_params)
      @location.events << @event
      @redirect_path = location_event_path(@location, @event, create: 1)

      respond_to do |format|
        format.json { render partial: 'events/event', object: @event }
      end
    end
  end

  private
  
  def find_or_create_location
    id = params.fetch(:location_id, nil)
    if id.present?
      Location.find(id)
    else
      Location.new(location_create_params).tap do |loc|
        LocationGeocoder.update(loc)
        loc.save!
      end
    end
  end
end
