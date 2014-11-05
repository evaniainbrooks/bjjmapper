#= require backbone/views/team-list-view

class RollFindr.Views.MapView extends Backbone.View
  el: $('.wrapper')
  tagName: 'div'
  map: null
  template: JST['templates/locations/map-list']
  teamFilter: null
  locationsView: null
  textFilter: null
  initialize: ->
    # TODO: Move this to a helper
    @circleDistance = (p0, p1) ->
      r = 3963.0
      lat1 = p0.lat().toRad()
      lon1 = p0.lng().toRad()
      lat2 = p1.lat().toRad()
      lon2 = p1.lng().toRad()

      return r * Math.acos(Math.sin(lat1) * Math.sin(lat2) + Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1))

    _.bindAll(this, 'search', 'setDefaultCenter', 'setCenter', 'setCenterGeolocate', 'createLocation', 'fetchViewport', 'render')

    mapOptions = {
      zoom: @model.get('zoom')
      minZoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
    }

    mapCanvas = @$('.map-canvas')[0]
    @map = new google.maps.Map(mapCanvas, mapOptions)

    @teamFilter = new RollFindr.Views.TeamListView({el: $('.filter-list')})
    @locationsView = new RollFindr.Views.MapViewLocations({map: @map, filters: @teamFilter, collection: @model.get('locations')})

    @listenTo(@teamFilter.collection, 'change:filter-active', @render)
    @listenTo(@model.get('locations'), 'sync', @render)

    google.maps.event.addListener(@map, 'click', @createLocation)
    google.maps.event.addListener(@map, 'idle', @fetchViewport)

    RollFindr.GlobalEvents.on('geolocate', @setCenterGeolocate)
    RollFindr.GlobalEvents.on('search', @search)

    @setCenter()
  visibleLocations: ->
    locations = _.chain(@model.get('locations').models)
    @teamFilter.filterCollection(locations).filter(
      (loc) =>
        coords = loc.get('coordinates')
        position = new google.maps.LatLng(coords[0], coords[1])
        return this.map.getBounds().contains(position)
    ).value()

  render: ->
    list = @template({locations: _.invoke(@visibleLocations(), 'toJSON')})
    $('.location-list', @el).html(list)
    @locationsView.render()

  search: (e)->
    @textFilter = e.query
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
    else
      @fetchViewport()


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

    distance = @circleDistance(@map.getCenter(), @map.getBounds().getNorthEast())

    @model.set('center', center)

    remove = @textFilter? && @textFilter.length > 0
    @model.get('locations').fetch({remove: remove, data: {query: @textFilter, center: center, distance: distance}})

