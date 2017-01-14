class RollFindr.Views.TeamShowView extends Backbone.View
  model: null
  mapModel: null
  mapView: null
  instructorView: null
  el: $('.show-team')
  initialize: (options)->
    instructorView = new RollFindr.Views.LocationInstructorsView({ model: options.model })
    mapView = new RollFindr.Views.MapView(model: options.mapModel, el: @$el)

