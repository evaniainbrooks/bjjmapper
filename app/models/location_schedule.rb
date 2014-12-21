require 'event_schedule'

class LocationSchedule
  def initialize(location_id)
    @location_id = location_id.to_s
  end

  def events_between_time(start_time, end_time)
    RollFindr::EventSchedule.new(single_events, recurring_events).events_between_time(start_time, end_time)
  end

  private

  def single_events
    @events ||= Event.where(:location_id => @location_id, :schedule => nil)
  end

  def recurring_events
    @recurring_events ||= Event.where(:location_id => @location_id, :schedule.ne => nil)
  end
end
