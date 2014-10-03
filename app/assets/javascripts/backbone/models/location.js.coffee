class RollFindr.Models.Location extends Backbone.Model
  paramRoot: 'location'
  urlRoot: Routes.locations_path
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
  url: Routes.search_locations_path
  sort_key: 'name'
  comparator:
    (item)->
      return item.get(this.sort_key)
  sortByField:
    (fieldName)->
      this.sort_key = fieldName
      this.sort()

