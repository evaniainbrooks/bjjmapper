require 'i18n'

class MapLocationDecorator < LocationDecorator 
  decorates :location

  def initialize(object, options = EMPTY_HASH)
    super(object, options)
    @event_type = context[:event_type]
    @location_type = context[:location_type]
    
    events = context.fetch(:events, [])
    @_events = EventDecorator.decorate_collection(events) if events.present?
  end

  def self.collection_decorator_class
    MapLocationsDecorator
  end

  def image
    if loctype == Location::LOCATION_TYPE_ACADEMY
      super
    elsif has_events?
      return events.first.image
    end
  end

  def title
    if loctype == Location::LOCATION_TYPE_ACADEMY
      return object.title
    elsif has_events?
      if events.count == 1
        return events.first.title
      else
        event_type_names = events.collect{|e|e.event_type_name.capitalize.pluralize}.uniq.sort.to_sentence
        return "#{events.count} #{event_type_names}"
      end
    end
  end

  def link
    if loctype == Location::LOCATION_TYPE_ACADEMY
      return h.location_path(location, ref: 'map_item')
    elsif has_events?
      if events.count == 1
        h.location_event_path(location, events.first, ref: 'map_item')
      else
        h.schedule_location_path(location, starting: events.first.starting, ref: 'map_item')
      end
    end
  end

  def dates
    return nil unless has_events?
    events.collect do |event|
      event.starting
    end.uniq.sort
  end

  def entities
    return nil unless has_events?
    events.collect do |event|
      event.organization.try(:abbreviation) || event.instructor.try(:name)
    end.compact.uniq.sort.to_sentence
  end

  def loctype
    return Location::LOCATION_TYPE_EVENT_VENUE if has_events? && @location_type && !@location_type.include?(Location::LOCATION_TYPE_ACADEMY)
    object.loctype
  end

  def events
    return @_events
  end

  def has_events?
    @_events.present?
  end
end

