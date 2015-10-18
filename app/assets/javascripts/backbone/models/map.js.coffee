class RollFindr.Models.Map extends Backbone.Model
  paramRoot: 'map'

  initialize: ->
    locationsCollection = new RollFindr.Collections.LocationsCollection(arguments[0].locations)
    this.set('locations', locationsCollection)

  defaults:
    zoom: 15
    center: [47.6097, -122.3331]
    editable: false
    geolocate: false
    geocodepath: null
    searchpath: null
    locations: []
