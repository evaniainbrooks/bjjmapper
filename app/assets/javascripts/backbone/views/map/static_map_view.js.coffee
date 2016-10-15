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

    @listView = new RollFindr.Views.MapListView({
      el: @$('.location-list')
      model: @model
      filteredCount: 0
    })

    @initializeMarkerView(options.editable)

    if @map?
      @setupEventListeners()
      @setCenterAndRefresh()
      if (@model.get('locations').size() == 1)
        id = @model.get('locations').first().get('id')
        RollFindr.GlobalEvents.trigger('markerActive', {id: id})

  initializeMarkerView: (editable)->
    shouldRender = @markerView?
    @markerView.destroy() if @markerView?

    templateFn = (loc)->
      return JST['templates/map/address-info-window']

    @markerView = new RollFindr.Views.MapMarkerView({template: templateFn, editable: editable, map: @map, model: @model})
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
      lat = locationModel.get('lat')
      lng = locationModel.get('lng')
      newCenter = new google.maps.LatLng(lat, lng)
      @map.setCenter(newCenter)

  render: ->
    @listView.render(0)
    @markerView.render()

  setCenterAndRefresh: ->
    lat = @model.get('lat')
    lng = @model.get('lng')

    defaultLocation = new google.maps.LatLng(lat, lng)
    @map.setCenter(defaultLocation)

    @model.get('locations').trigger('reset')

