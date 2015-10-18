class RollFindr.Views.StaticMapView extends Backbone.View
  el: $('.wrapper')
  map: null
  markerView: null
  listView: null
  initialize: (options)->
    _.bindAll(this,
      'activeMarkerChanged',
      'setupEventListeners',
      'setupGoogleMap',
      'setCenterAndRefresh',
      'initializeMarkerView',
      'render')

    @setupGoogleMap()

    @listView = new RollFindr.Views.MapLocationsListView({
      el: @$('.location-list')
      collection: @model.get('locations')
      filteredCount: 0
    })

    @initializeMarkerView(options.editable)

    if @map?
      @setupEventListeners()
      @setCenterAndRefresh()

  initializeMarkerView: (editable)->
    shouldRender = @markerView?
    @markerView.destroy() if @markerView?

    @markerView = new RollFindr.Views.MapMarkerView({editable: editable, map: @map, collection: @model.get('locations')})
    @markerView.render() if shouldRender

  setupGoogleMap: ->
    mapOptions = {
      mapTypeControl: false
      zoom: @model.get('zoom')
      minZoom: @model.get('minZoom')
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    mapCanvas = @$('.map-canvas')[0]

    @map = new google.maps.Map(mapCanvas, mapOptions)

  setupEventListeners: ->
    @listenTo(@model.get('locations'), 'sort sync reset', @render)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)

  activeMarkerChanged: (e)->
    if null != e.id
      locationModel = @model.get('locations').findWhere({id: e.id})
      coordinates = locationModel.get('coordinates')
      newCenter = new google.maps.LatLng(coordinates[0], coordinates[1])
      @map.setCenter(newCenter)

  render: ->
    @listView.render(0)
    @markerView.render()

  setCenterAndRefresh: ->
    defaultCenter = @model.get('center')
    defaultCenter = [47.718415099999994, -122.31384220000001] if defaultCenter.length < 2

    defaultLocation = new google.maps.LatLng(defaultCenter[0], defaultCenter[1])
    google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)
    @map.setCenter(defaultLocation)

    @model.get('locations').trigger('reset')

