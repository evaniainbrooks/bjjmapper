#= require distance
#= require backbone/views/map/create_location_view
#= require backbone/views/map/directions_dialog_view

class RollFindr.Views.MapView extends Backbone.View
  el: $('.wrapper')
  map: null
  directionsView: null
  markerView: null
  listView: null
  events: {
    'change [name="sort_order"]': 'sortOrderChanged'
    'click .refresh-button': 'clearSearchAndFetchViewport'
  }
  initialize: (options)->
    _.bindAll(this,
      'activeMarkerChanged',
      'clearSearchAndFetchViewport',
      'search',
      'setCenterFromModelAndRefresh',
      'initializeMarkerView',
      'initializeMap',
      'setCenterGeolocate',
      'setCenterGeocode',
      'fetchViewport',
      'geolocate',
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
      @initializeMap()
      @directionsView = new RollFindr.Views.DirectionsOverlayView({el: @el, model: @model, map: @map})

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

    if @model.get('refresh')
      refreshButton = JST['templates/refresh_button']()
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push($(refreshButton)[0])
      @createLocationView = new RollFindr.Views.MapCreateLocationView({map: @map})

    if @model.get('legend')
      @legendView = new RollFindr.Views.MapLegendView({map: @map, model: @model})

  setupEventListeners: ->
    @listenTo(@model.get('locations'), 'sort sync reset', @render)

    filtersChanged = _.debounce(@fetchViewport, 500)
    @model.on('change:event_type', filtersChanged)
    @model.on('change:location_type', filtersChanged)

    RollFindr.GlobalEvents.on('geolocate', @geolocate)
    RollFindr.GlobalEvents.on('search', @search)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)
    RollFindr.GlobalEvents.on('editing', @initializeMarkerView)

  activeMarkerChanged: (e)->
    if null != e.id
      locationModel = @model.get('locations').findWhere({id: e.id})
      lat = locationModel.get('lat')
      lng = locationModel.get('lng')
      newCenter = new google.maps.LatLng(lat, lng)
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

    @setCenterGeocode =>
      @fetchViewport()

  geolocate: ->
    @setCenterGeolocate =>
      @fetchViewport()

  setCenterGeolocate: (doneCallback)->
    geolocateSuccessCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      @map.setCenter(initialLocation)
      doneCallback() if doneCallback?

    geolocateFailedCallback = =>
      userModelLocation = new google.maps.LatLng(RollFindr.CurrentUser.get('lat'), RollFindr.CurrentUser.get('lng'))
      @map.setCenter(userModelLocation)

      toastr.error('Could not pinpoint your location', 'Error')
      doneCallback() if doneCallback?

    if navigator? && navigator.geolocation?
      options = { enableHighAccuracy: true }
      navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback, options)
    else
      geolocateFailedCallback()

  initializeMap: ->
    shouldGeolocate = @model.get('geolocate')
    hasQuery = @model.get('query')? && @model.get('query').length > 0
    hasCenter = @model.get('lat')? && @model.get('lng')?

    if (shouldGeolocate && navigator.geolocation)
      @setCenterGeolocate =>
        @fetchViewport()
    else if !hasQuery && hasCenter
      @setCenterFromModelAndRefresh()
    else
      @setCenterGeocode =>
        @fetchViewport()

  setCenterFromModelAndRefresh: ->
    defaultLat = @model.get('lat')
    defaultLng = @model.get('lng')
    defaultLocation = new google.maps.LatLng(defaultLat, defaultLng)
    google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)
    @map.setCenter(defaultLocation)

  setCenterGeocode: (doneCallback)->
    $.ajax({
      url: Routes.geocoder_path(),
      data: {
        query: @model.get('location'),
      },
      type: 'GET',
      dataType: 'json',
      success: (results) =>
        google.maps.event.addListenerOnce(@map, 'idle', doneCallback)
        newCenter = new google.maps.LatLng(results[0].lat, results[0].lng)
        @map.setZoom(7)
        @map.setCenter(newCenter)
    })

  fetchGlobal: ->
    @model.get('locations').fetch({
      data:
        event_type: @model.get('event_type')
        location_type: @model.get('location_type')
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
          @setCenterGeocode =>
            @fetchViewport()
        else if !@map.getCenter()?
          toastr.warning('Your search query did not return any results', 'Oops')
          @setCenterFromModelAndRefresh()

      error: =>
        toastr.error('Failed to refresh map', 'Error')
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

    lat = @map.getCenter().lat()
    lng = @map.getCenter().lng()

    distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())

    @model.set('lat', lat)
    @model.set('lng', lng)
    @$('.refresh-button .fa').addClass('fa-spin')

    @model.get('locations').fetch({
      data:
        location_type: @model.get('location_type')
        event_type: @model.get('event_type')
        lat: lat
        lng: lng
        distance: distance
        query: @model.get('query')
        location: @model.get('location')
      complete: =>
        @$('.refresh-button .fa').removeClass('fa-spin')
      error: =>
        toastr.error('Failed to refresh map', 'Error')
    })

