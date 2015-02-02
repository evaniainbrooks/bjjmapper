#= require distance
#= require term-filter
#= require backbone/views/team-list-view
#= require backbone/views/map/create_location_view
#= require backbone/views/map/directions_dialog_view

class RollFindr.Views.MapView extends Backbone.View
  directionsDisplay: new google.maps.DirectionsRenderer()
  directionsDialog: null
  el: $('.wrapper')
  map: null
  teamFilter: null
  termFilter: null
  locationsView: null
  listView: null
  filteredLocations: new RollFindr.Collections.LocationsCollection()
  events: {
    'change [name="sort_order"]': 'sortOrderChanged'
    'click .refresh-button': 'fetchViewport'
    'click a.directions': 'getDirections'
    'click .directions-panel .close' : 'hideDirectionsOverlay'
  }
  initialize: ->
    _.bindAll(this,
      'activeMarkerChanged',
      'search',
      'setDefaultCenter',
      'setDirectionsOverlay',
      'hideDirectionsOverlay',
      'setCenter',
      'setCenterGeolocate',
      'fetchViewport',
      'geolocate',
      'render',
      'filtersChanged')

    @setupGoogleMap()

    @termFilter = new TermFilter()
    @teamFilter = new RollFindr.Views.TeamListView({el: @$('.filter-list .team-list')})

    @locationsView = new RollFindr.Views.MapMarkerView({map: @map, collection: @filteredLocations})
    @listView = new RollFindr.Views.MapLocationsListView({
      el: @$('.location-list')
      collection: @filteredLocations
      filteredCount: 0
    })

    if @map?
      @setupEventListeners()
      @setCenter()

  hideDirectionsOverlay: ->
    @map.controls[google.maps.ControlPosition.RIGHT_CENTER].clear()
    @directionsDisplay.setMap(null)

  setupGoogleMap: ->
    mapOptions = {
      zoom: @model.get('zoom')
      minZoom: 6
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    mapCanvas = @$('.map-canvas')[0]
    return false unless mapCanvas?

    @map = new google.maps.Map(mapCanvas, mapOptions)

    if @model.get('refresh')
      refreshButton = JST['templates/refresh_button']()
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push($(refreshButton)[0])
      @createLocationView = new RollFindr.Views.MapCreateLocationView({map: @map})

  setupEventListeners: ->
    @listenTo(@teamFilter.collection, 'change:filter-active sync', @filtersChanged)
    @listenTo(@termFilter.collection, 'sync reset', @filtersChanged)
    @listenTo(@model.get('locations'), 'sort sync reset', @filtersChanged)

    #google.maps.event.addListener(@map, 'click', @createLocation)
    #google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)

    RollFindr.GlobalEvents.on('geolocate', @geolocate)
    RollFindr.GlobalEvents.on('search', @search)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)
    RollFindr.GlobalEvents.on('directions', @setDirectionsOverlay)

  activeMarkerChanged: (e)->
    if null != e.id
      locationModel = @filteredLocations.findWhere({id: e.id})
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

  filtersChanged: ->
    locations = @model.get('locations')
    locations = @teamFilter.filterCollection(locations)
    locations = @termFilter.filterCollection(locations)

    @filteredLocations.reset(if locations.models then locations.models else locations)
    @render()

  render: ->
    filteredCount = @model.get('locations').models.length - @filteredLocations.models.length
    @listView.render(filteredCount)
    @locationsView.render()

  search: (e)->
    if e.location? && e.location.length > 0
      $.ajax({
        url: Routes.geocode_path(),
        data: {
          query: e.location,
        },
        type: 'GET',
        dataType: 'json',
        success: (results) =>
          google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)

          newCenter = new google.maps.LatLng(results[0].lat, results[0].lng)
          @map.setCenter(newCenter)
          @setTermFilterQuery(e.query)
      })
    else
      @setTermFilterQuery(e.query)

  setTermFilterQuery: (query)->
      center = [@map.getCenter().lat(), @map.getCenter().lng()]
      distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())
      distance *= 3
      @termFilter.setQuery(query, center, distance)

  geolocate: ->
    @setCenterGeolocate =>
      @fetchViewport()

  setCenterGeolocate: (doneCallback)->
    geolocateSuccessCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      @map.setCenter(initialLocation)
      doneCallback() if doneCallback?

    geolocateFailedCallback = =>
      toastr.error('Could not pinpoint your location', 'Error')

    navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback) if navigator? && navigator.geolocation?

  setCenter: ->
    shouldGeolocate = @model.get('geolocate')
    if (shouldGeolocate && navigator.geolocation)
      @setCenterGeolocate =>
        @fetchViewport()
    else
      @setDefaultCenter()

  setDefaultCenter: ->
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

