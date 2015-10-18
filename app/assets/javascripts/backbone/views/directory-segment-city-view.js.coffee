class RollFindr.Views.DirectorySegmentCityView extends Backbone.View
  model: null
  mapView: null
  calendarView: null

  initialize: (options)->
    _.bindAll(this, 'initializeMap', 'initializeCalendar')

    @initializeMap(options.mapModel)
    @initializeCalendar(options.model.get('locations'))

  initializeCalendar: (locations) ->
    calendarView = new RollFindr.Views.OmniCalendarView(collection: locations)

  initializeMap: (model)->
    mapView = new RollFindr.Views.StaticMapView(model: model, el: @$el)

