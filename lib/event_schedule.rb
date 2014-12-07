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
        recurrence = event.event_recurrence
        schedule = IceCube::Schedule.new(event.starting)
        schedule.add_recurrence_rule(recurrence.rule)

        schedule.occurrences(end_time).each do |occurrence|
          events << create_event_occurrence(occurrence, event) if occurrence >= start_time
        end
      end

      events
    end

    def create_event_occurrence(occurrence, event)
      Event.new.tap do |e|
        e.title = event.title
        e.description = event.description
        e.starting = occurrence_start(occurrence, event)
        e.ending = occurrence_end(occurrence, event)
        e.location = event.location
        e.instructor = event.instructor
      end
    end

    def occurrence_start(occurrence, event)
      (occurrence.to_time.beginning_of_day + (event.starting.to_i - event.starting.beginning_of_day.to_i).seconds)
    end

    def occurrence_end(occurrence, event)
      (occurrence.to_time.beginning_of_day + (event.ending.to_i - event.ending.beginning_of_day.to_i).seconds)
    end

    def single_events_between_time(start_time, end_time)
      @single_events.between_time(start_time, end_time)
    end
  end
end
