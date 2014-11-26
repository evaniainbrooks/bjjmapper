#= require distance
#= require term-filter
#= require backbone/views/team-list-view

class RollFindr.Views.MapView extends Backbone.View
  el: $('.wrapper')
  tagName: 'div'
  map: null
  teamFilter: null
  termFilter: null
  locationsView: null
  listView: null
  filteredLocations: new RollFindr.Collections.LocationsCollection()
  events: {
    'change [name="sort_order"]': 'sortOrderChanged'
    'click .refresh-button': 'fetchViewport'
    'click .add-academy': 'addAcademyClicked'
    'click .cancel-add-academy': 'cancelAddAcademyClicked'
  }
  initialize: ->
    _.bindAll(this,
      'activeMarkerChanged',
      'search',
      'setDefaultCenter',
      'setCenter',
      'setCenterGeolocate',
      'addAcademyClicked',
      'cancelAddAcademyClicked',
      'fetchViewport',
      'geolocate',
      'render',
      'filtersChanged')

    @setupGoogleMap()

    @termFilter = new TermFilter()
    @teamFilter = new RollFindr.Views.TeamListView({el: @$('.filter-list .team-list')})

    @locationsView = new RollFindr.Views.MapViewLocations({map: @map, collection: @filteredLocations})
    @listView = new RollFindr.Views.MapViewList({
      el: @$('.location-list')
      collection: @filteredLocations
      filteredCount: 0
    })

    @setupEventListeners()
    @setCenter()

  setupGoogleMap: ->
    mapOptions = {
      zoom: @model.get('zoom')
      minZoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }
    mapCanvas = @$('.map-canvas')[0]
    @map = new google.maps.Map(mapCanvas, mapOptions)

    if @model.get('refresh')
      refreshButton = JST['templates/refresh_button']()
      @map.controls[google.maps.ControlPosition.TOP_LEFT].push($(refreshButton)[0])

  setupEventListeners: ->
    @listenTo(@teamFilter.collection, 'change:filter-active', @filtersChanged)
    @listenTo(@termFilter.collection, 'sync reset', @filtersChanged)
    @listenTo(@model.get('locations'), 'sort sync reset', @filtersChanged)

    #google.maps.event.addListener(@map, 'click', @createLocation)
    google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)

    RollFindr.GlobalEvents.on('geolocate', @geolocate)
    RollFindr.GlobalEvents.on('search', @search)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)

  activeMarkerChanged: (e)->
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
        success: (result) =>
          google.maps.event.addListenerOnce(@map, 'idle', @fetchViewport)

          newCenter = new google.maps.LatLng(result.lat, result.lng)
          @map.setCenter(newCenter)
      })

    center = [@map.getCenter().lat(), @map.getCenter().lng()]
    distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())
    distance *= 5
    @termFilter.setQuery(e.query, center, distance)

  cancelAddAcademyClicked: (event)->
    mixpanel.track('clickCancelAddAcademy')

    toastr.clear()

    @$el.removeClass('map-edit-mode')
    google.maps.event.removeListener(@mapClickHandler) if @mapClickHandler?

    @editModeToast = null
    @mapClickHandler = null

  addAcademyClicked: (event)->
    mixpanel.track('clickAddAcademy')

    if RollFindr.CurrentUser.isAnonymous()
      $('.login-modal').modal('show')
      return false

    @editModeToast = toastr.info('Just click on the map at the approximate location', 'To add a new academy')
    @$el.addClass('map-edit-mode')
    @mapClickHandler = google.maps.event.addListener @map, 'click', (event)=>
      mixpanel.track('clickMap', {
        lat: event.latLng.lat(),
        lng: event.latLng.lng()
      })

      toastr.clear()
      $('.coordinates', '.new-location-dialog').val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]))
      $('.new-location-dialog').modal('show')

  geolocate: ->
    @setCenterGelocate =>
      @fetchViewport()

  setCenterGeolocate: (doneCallback)->
    setLocationCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude)
      @map.setCenter(initialLocation)
      doneCallback() if doneCallback?

    navigator.geolocation.getCurrentPosition(setLocationCallback, @setDefaultCenter) if navigator? && navigator.geolocation?

  setCenter: ->
    shouldGeolocate = @model.get('geolocate')
    if (shouldGeolocate && navigator.geolocation)
      @setCenterGeolocate =>
        @fetchViewport()
    else
      @setDefaultCenter()

  setDefaultCenter: ->
    defaultCenter = @model.get('center')
    defaultLocation = new google.maps.LatLng(defaultCenter[0], defaultCenter[1])
    @map.setCenter(defaultLocation)

  fetchViewport: ->
    if (undefined == @map.getCenter() || undefined == @map.getBounds())
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
        toastr.error('Failed to refresh map')
    })
