class RollFindr.Views.DirectionsOverlayView extends Backbone.View
  directionsDisplay: new google.maps.DirectionsRenderer()
  directionsDialog: null
  map: null
  model: null
  events: {
    'click a.directions': 'getDirections'
    'click .directions-panel .close' : 'hideDirectionsOverlay'
  }

  initialize: (options)->
    _.bindAll(this,
      'getDirections',
      'setupEventListeners',
      'setDirectionsOverlay',
      'hideDirectionsOverlay')

    @setupEventListeners()

  setDirectionsOverlay: (e)->
    directionsOverlay = JST['templates/directions_overlay']()
    @map.controls[google.maps.ControlPosition.RIGHT_CENTER].push($(directionsOverlay)[0])

    @directionsDisplay.setDirections(e.result)
    @directionsDisplay.setPanel($('.directions-panel')[0])
    @directionsDisplay.setMap(@map)

    RollFindr.GlobalEvents.trigger('markerActive', {id: null})

  hideDirectionsOverlay: ->
    @map.controls[google.maps.ControlPosition.RIGHT_CENTER].clear()
    @directionsDisplay.setMap(null)

  getDirections: (e)->
    id = $(e.currentTarget).data('id')
    location = @model.get('locations').get(id)

    @directionsDialog.undelegateEvents() if @directionsDialog?
    @directionsDialog = new RollFindr.Views.DirectionsDialogView({el: $('.directions-dialog-container'), model: location})
    return false

  setupEventListeners: ->
    RollFindr.GlobalEvents.on('directions', @setDirectionsOverlay)

