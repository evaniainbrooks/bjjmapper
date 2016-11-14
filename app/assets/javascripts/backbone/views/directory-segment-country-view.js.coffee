class RollFindr.Views.DirectorySegmentCountryView extends Backbone.View
  model: null
  mapView: null
  upcomingView: null

  initialize: (options)->
    _.bindAll(this, 'initializeMap')

    @initializeMap(options.mapModel)
    @upcomingView = new RollFindr.Views.UpcomingEventsView()

  initializeMap: (model)->
    mapView = new RollFindr.Views.StaticMapView(model: model, el: @$('.map-view'))
