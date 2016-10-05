class MapLocationsDecorator < Draper::CollectionDecorator
  def initialize(object, options = {})
    super(object, options)
    @_events = context.delete(:events)
  end

  def decorate_item(item)
    item_decorator.call(item, context: context.merge(events: @_events[item.id]))
  end
end
