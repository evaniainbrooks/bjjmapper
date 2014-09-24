class RollFindr.Models.Map extends Backbone.Model
  paramRoot: 'map'

  defaults:
    zoom: 15
    center: [47.6097, -122.3331]
    editable: false
    geolocate: false
    geocodepath: null
    searchpath: null
