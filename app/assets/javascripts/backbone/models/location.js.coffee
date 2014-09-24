class RollFindr.Models.Location extends Backbone.Model
  paramRoot: 'location'

  defaults:
    title: null
    description: null
    directions: null
    street: null
    city: null
    postal_code: null
    state: null
    country: null
    id: null
    team_id: null
    coordinates: []

class RollFindr.Collections.LocationsCollection extends Backbone.Collection
  model: RollFindr.Models.Location
  url: '/locations'