class RollFindr.Models.Location extends Backbone.Model
  initialize: ->
    id = this.get('id')
    instructors = this.get('instructors').map (obj)->
      {
        id: obj,
        location_id: id
      }

    instructorsCollection = new RollFindr.Collections.InstructorsCollection(instructors, {location_id: id})
    this.set('instructors', instructorsCollection)

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
    instructors: []

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

