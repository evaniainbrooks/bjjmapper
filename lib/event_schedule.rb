module RollFindr
  class EventSchedule
    def initialize(single_events, recurring_events)
      @single_events = single_events
      @recurring_events = recurring_events
    end
    def events_between_time(start_time, end_time)
      events = []
      events.concat(single_events_between_time(start_time, end_time).to_a)
      events.concat(recurring_events_between_time(start_time, end_time).to_a)
    end

    protected

    def recurring_events_between_time(start_time, end_time)
      events = []
      @recurring_events.each do |event|
        event.schedule.occurrences(end_time).each do |occurrence|
          events << create_event_occurrence(occurrence, event) if occurrence >= start_time
        end
      end

      events
    end

    def create_event_occurrence(occurrence, event)
      Event.new.tap do |e|
        e.id = event.id
        e.title = event.title
        e.description = event.description
        e.location = event.location
        e.starting = occurrence_start(occurrence, event).in_time_zone(e.location.timezone)
        e.ending = occurrence_end(occurrence, event).in_time_zone(e.location.timezone)
        e.instructor = event.instructor
      end
    end

    def occurrence_start(occurrence, event)
      occurrence
    end

    def occurrence_end(occurrence, event)
      occurrence + (event.ending - event.starting)
    end

    def single_events_between_time(start_time, end_time)
      @single_events.between_time(start_time, end_time)
    end
  end
end
