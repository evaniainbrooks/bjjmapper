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
    'click .location-list a': 'listItemClicked'
  }
  initialize: ->
    _.bindAll(this, 'activeMarkerChanged', 'search', 'setDefaultCenter', 'listItemClicked', 'setCenter', 'setCenterGeolocate', 'createLocation', 'fetchViewport', 'render', 'filtersChanged')

    mapOptions = {
      zoom: @model.get('zoom')
      minZoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }

    mapCanvas = @$('.map-canvas')[0]
    @map = new google.maps.Map(mapCanvas, mapOptions)

    @termFilter = new TermFilter()
    @teamFilter = new RollFindr.Views.TeamListView({el: @$('.filter-list .team-list')})
    @locationsView = new RollFindr.Views.MapViewLocations({map: @map, collection: @filteredLocations})

    @listenTo(@teamFilter.collection, 'change:filter-active', @filtersChanged)
    @listenTo(@termFilter.collection, 'sync reset', @filtersChanged)
    @listenTo(@model.get('locations'), 'sort sync reset', @filtersChanged)

    google.maps.event.addListener(@map, 'click', @createLocation)
    google.maps.event.addListener(@map, 'idle', @fetchViewport)

    RollFindr.GlobalEvents.on('geolocate', @setCenterGeolocate)
    RollFindr.GlobalEvents.on('search', @search)
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)

    @setCenter()

  activeMarkerChanged: (e)->
    # Set active marker in list

  listItemClicked: (e)->
    id = $(e.currentTarget).data('id')
    locationModel = @filteredLocations.findWhere({id: id})
    coordinates = locationModel.get('coordinates')
    newCenter = new google.maps.LatLng(coordinates[0], coordinates[1])

    @map.setCenter(newCenter)
    RollFindr.GlobalEvents.trigger('markerActive', {id: id})
    e.preventDefault();

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
    @listView = new RollFindr.Views.MapViewList({
      el: @$('.location-list')
      collection: @visibleLocations()
      filteredCount: filteredCount
    })

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
          newCenter = new google.maps.LatLng(result.lat, result.lng)
          @map.setCenter(newCenter)
      })

    center = [@map.getCenter().lat(), @map.getCenter().lng()]
    distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())
    distance *= 5
    @termFilter.setQuery(e.query, center, distance)

  createLocation: (event)->
    $('.coordinates', '.new-location-dialog').val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]))
    $('.new-location-dialog').modal('show')

  setCenterGeolocate: ->
    setLocationCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude)
      @map.setCenter(initialLocation)

    navigator.geolocation.getCurrentPosition(setLocationCallback, @setDefaultCenter) if navigator? && navigator.geolocation?

  setCenter: ->
    shouldGeolocate = @model.get('geolocate')
    if (shouldGeolocate && navigator.geolocation)
      @setCenterGeolocate()
    else
      @setDefaultCenter()

  setDefaultCenter: ->
    defaultCenter = @model.get('center')
    defaultLocation = new google.maps.LatLng(defaultCenter[0], defaultCenter[1])
    @map.setCenter(defaultLocation)

  fetchViewport: ->
    center = @model.get('center')
    center[0] = @map.getCenter().lat()
    center[1] = @map.getCenter().lng()

    distance = Math.circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())

    @model.set('center', center)
    @model.get('locations').fetch({remove: false, data: {center: center, distance: distance}})

