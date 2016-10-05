class MoveEvent
  MOVE_ALL = 1
  MOVE_FUTURE = 2
  MOVE_SINGLE = 3

  def initialize(event, move_type)
    @move_type = move_type
    @event = event
  end

  def move(instance_starting, instance_ending, delta_seconds)
    case @move_type
    when MOVE_ALL then return move_event(@event, delta_seconds)
    when MOVE_FUTURE then return move_future(@event, instance_starting, instance_ending, delta_seconds)
    when MOVE_SINGLE then return move_single(@event, instance_starting, instance_ending, delta_seconds)
    else return @event
    end
  end

  private

  def move_single(event, instance_starting, instance_ending, delta_seconds)
    create_event(event, instance_starting, instance_ending, delta_seconds, nil)
    create_single_exception(event, instance_starting)
    return event
  end

  def move_future(event, instance_starting, instance_ending, delta_seconds)
    create_event(event, instance_starting, instance_ending, delta_seconds, event.schedule)
    create_future_exception(event, instance_starting)
    return event
  end

  def move_event(event, delta_seconds)
    event.tap do |e|
      e.starting = event.starting + delta_seconds
      e.ending = event.ending + delta_seconds
      e.schedule.start_time = e.schedule.start_time + delta_seconds
    end
  end

  def create_single_exception(event, instance_starting)
    event.schedule.add_exception_time(instance_starting)
  end

  def create_future_exception(event, instance_starting)
    event.schedule.end_time = instance_starting.beginning_of_day
  end

  def create_event(event, instance_starting, instance_ending, delta_seconds, schedule)
    puts "creating event"
    event.dup.tap do |e|
      e.schedule = schedule.try(:dup)
      e.schedule.start_time = instance_starting if e.schedule
      e.starting = instance_starting
      e.ending = instance_ending
      move_event(e, delta_seconds)
      e.save
      puts e.errors.messages
    end
  end
end
