module RollFindr
  class EventSchedule
    def initialize(single_events, recurring_events)
      @single_events = single_events
      @recurring_events = recurring_events
    end
    def events_between_time(start_time, end_time)
      events = []
      events.concat(single_events_between_time(start_time, end_time).to_a) if @single_events
      events.concat(recurring_events_between_time(start_time, end_time).to_a) if @recurring_events
    end

    protected

    def recurring_events_between_time(start_time, end_time)
      @recurring_events.reduce([]) do |result, event|
        occurrences = event.schedule.occurrences_between(start_time, end_time).map do |occurrence|
          create_event_occurrence(occurrence, event)
        end

        result.concat(occurrences)
      end
    end

    def create_event_occurrence(occurrence, event)
      event.dup.tap do |e|
        e.starting = occurrence_start(occurrence, event).in_time_zone(e.location.timezone)
        e.ending = occurrence_end(occurrence, event).in_time_zone(e.location.timezone)
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
