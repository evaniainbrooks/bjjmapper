#= require backbone/models/event
#= require backbone/models/location

class RollFindr.Models.Map extends Backbone.Model
  paramRoot: 'map'
  urlRoot: Routes.search_map_path()

  initialize: (options)->
    locations = options.locations if options?
    locationsCollection = new RollFindr.Collections.LocationsCollection(locations)
    this.set('locations', locationsCollection)
    this.listenTo(this, 'change:locations', this.onChangeLocations)

  onChangeLocations: =>
    locations = @get('locations')
    if Object.prototype.toString.call(locations) == '[object Array]'
      @set('locations', new RollFindr.Collections.LocationsCollection(locations), {silent: true})

  defaults:
    zoom: 15
    lat: 47.6097
    lng: -122.3331
    editable: false
    geolocate: false
    geocodepath: null
    searchpath: null
    locations: []
    location_type: []
    event_type: []
