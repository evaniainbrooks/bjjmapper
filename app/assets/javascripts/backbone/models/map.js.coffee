class RollFindr.Models.Map extends Backbone.Model
  paramRoot: 'map'

  defaults:
    zoom: 15
    center: [47.6097, -122.3331]
    editable: false
    geolocate: false
    geocodepath: null
    searchpath: null

class RollFindr.Collections.MapsCollection extends Backbone.Collection
  model: RollFindr.Models.Map
  url: '/maps'
