#= require distance
#= require backbone/views/map/create_location_view
#= require backbone/views/map/directions_dialog_view

class RollFindr.Views.MapView extends Backbone.View
  directionsDisplay: new google.maps.DirectionsRenderer()
  directionsDialog: null
  el: $('.wrapper')
  map: null
  teamFilter: null
  markerView: null
  listView: null
  events: {
    'change [name="sort_order"]': 'sortOrderChanged'
    'click .refresh-button': 'clearSearchAndFetchViewport'
    'click a.directions': 'getDirections'
    'click .directions-panel .close' : 'hideDirectionsOverlay'
  }
  initialize: (options)->
    _.bindAll(this,
      'activeMarkerChanged',
      'search',
      'setCenterFromModelAndRefresh',
      'setDirectionsOverlay',
      'hideDirectionsOverlay',
      'initializeMarkerView',
      'setCenterAndFetchLocations',
      'setCenterGeolocate',
      'clearSearchAndFetchViewport',
      'fetchViewport',
      'fetchGlobal',
      'geolocate',
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
      @setCenterAndFetchLocations()

  initializeMarkerView: (editable)->
    shouldRender = @markerView?
    @markerView.destroy() if @markerView?

    @markerView = new RollFindr.Views.MapMarkerView({editable: editable, map: @map, collection: @model.get('locations')})
    @markerView.render() if shouldRender

  hideDirectionsOverlay: ->
    @map.controls[google.maps.ControlPosition.RIGHT_CENTER].clear()
    @directionsDisplay.setMap(null)

  setupGoogleMap: ->
    mapOptions = {
      zoom: @model.get('zoom')
      minZoom: @model.get('minZoom')
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    mapCanvas = @$('.map-canvas')[0]

    @map = new google.maps.Map(mapCanvas, mapOptions)

    if @model.get('refresh')
      refreshButton = JST['templates/refresh_button']()
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push($(refreshButton)[0])
      @createLocationView = new RollFindr.Views.MapCreateLocationView({map: @map})

  setupEventListeners: ->
    @listenTo(@model.get('locations'), 'sort sync reset', @render)

    RollFindr.GlobalEvents.on('geolocate', @geolocate)
    RollFindr.GlobalEvents.on('search', @search)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)
    RollFindr.GlobalEvents.on('directions', @setDirectionsOverlay)
    RollFindr.GlobalEvents.on('editing', @initializeMarkerView)

  activeMarkerChanged: (e)->
    if null != e.id
      locationModel = @model.get('locations').findWhere({id: e.id})
      coordinates = locationModel.get('coordinates')
      newCenter = new google.maps.LatLng(coordinates[0], coordinates[1])
      @map.setCenter(newCenter)

  visibleLocations: ->
    @filteredLocations.filter(
      (loc) =>
        coords = loc.get('coordinates')
        position = new google.maps.LatLng(coords[0], coords[1])
        return this.map.getBounds().contains(position)
    )
  sortOrderChanged: (e)->
    selectedSort = $('option:selected', e.currentTarget)
    @model.get('locations').sortByField(selectedSort.val())

  render: ->
    #filteredCount = @model.get('locations').models.length - @filteredLocations.models.length
    @listView.render(0)
    @markerView.render()

  search: (e)->
    @model.set('query', e.query)
    @model.set('location', e.location)

    @fetchGlobal()

  geolocate: ->
    @setCenterGeolocate =>
      @fetchViewport()

  setCenterGeolocate: (doneCallback)->
    geolocateSuccessCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      @map.setCenter(initialLocation)
      doneCallback() if doneCallback?

    geolocateFailedCallback = =>
      @setCenterFromModelAndRefresh()
      toastr.error('Could not pinpoint your location', 'Error')

    navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback) if navigator? && navigator.geolocation?

  setCenterAndFetchLocations: ->
    shouldGeolocate = @model.get('geolocate')
    hasQuery = @model.get('query')? && @model.get('query').length > 0
    hasCenter = @model.get('center')? && @model.get('center').length > 0
    if (shouldGeolocate && navigator.geolocation)
      @setCenterGeolocate =>
        @fetchViewport()
    else if !hasQuery && hasCenter
      @setCenterFromModelAndRefresh()
    else
      @fetchGlobal()

  setCenterFromModelAndRefresh: ->
    defaultCenter = @model.get('center')
    defaultCenter = [47.718415099999994, -122.31384220000001] if defaultCenter.length < 2

    defaultLocation = new google.maps.LatLng(defaultCenter[0], defaultCenter[1])
    google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)
    @map.setCenter(defaultLocation)

  setDirectionsOverlay: (e)->
    directionsOverlay = JST['templates/directions_overlay']()
    @map.controls[google.maps.ControlPosition.RIGHT_CENTER].push($(directionsOverlay)[0])

    @directionsDisplay.setDirections(e.result)
    @directionsDisplay.setPanel($('.directions-panel')[0])
    @directionsDisplay.setMap(@map)

    RollFindr.GlobalEvents.trigger('markerActive', {id: null})


  fetchGlobal: ->
    @model.get('locations').fetch({
      data:
        query: @model.get('query')
        location: @model.get('location')
      complete: =>
        firstLocation = @model.get('locations').models[0]
        if firstLocation?
          coords = firstLocation.get('coordinates')
          newCenter = new google.maps.LatLng(coords[0], coords[1])

          @model.set('center', coords)
          @map.setCenter(newCenter)

          @$('.refresh-button .fa').removeClass('fa-spin')
        else if @model.get('location')?
          @setMapCenterFromLocationQuery()
        else if !@map.getCenter()?
          toastr.warning('Your search query did not return any results', 'Oops')
          @setCenterFromModelAndRefresh()

      error: =>
        toastr.error('Failed to refresh map', 'Error')
    })


  setMapCenterFromLocationQuery: ->
    $.ajax({
      url: Routes.geocode_path(),
      data: {
        query: @model.get('location'),
      },
      type: 'GET',
      dataType: 'json',
      success: (results) =>
        google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)
        newCenter = new google.maps.LatLng(results[0].lat, results[0].lng)
        @map.setZoom(7)
        @map.setCenter(newCenter)
    })


  clearSearch: ->
    @model.set('query', null)
    @model.set('location', null)

  clearSearchAndFetchViewport: ->
    @clearSearch()
    @fetchViewport()

  fetchViewport: ->
    if (undefined == @map.getCenter() || undefined == @map.getBounds())
      google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)
      return

    center = @model.get('center')
    center[0] = @map.getCenter().lat()
    center[1] = @map.getCenter().lng()

    distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())

    @model.set('center', center)
    @$('.refresh-button .fa').addClass('fa-spin')

    @model.get('locations').fetch({
      data:
        center: center
        distance: distance
        query: @model.get('query')
        location: @model.get('location')
      complete: =>
        @$('.refresh-button .fa').removeClass('fa-spin')
      error: =>
        toastr.error('Failed to refresh map', 'Error')
    })

  getDirections: (e)->
    id = $(e.currentTarget).data('id')
    location = @model.get('locations').get(id)

    @directionsDialog.undelegateEvents() if @directionsDialog?
    @directionsDialog = new RollFindr.Views.DirectionsDialogView({el: $('.directions-dialog-container'), model: location})
    return false

