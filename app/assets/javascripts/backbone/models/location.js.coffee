class RollFindr.Models.Location extends Backbone.Model
  initialize: ->
    id = this.get('id')
    instructors = @get('instructors')
    instructors = new RollFindr.Collections.InstructorsCollection(instructors, {location_id: id})
    this.set('instructors', instructors)
    reviews = @get('reviews')
    reviews = new RollFindr.Collections.ReviewsCollection(reviews, {location_id: id})
    this.set('reviews', reviews)

  isVisible: (center, radius)->
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
  url: Routes.search_locations_path()
  sort_key: 'name'
  comparator:
    (item)->
      return item.get(this.sort_key)
  sortByField:
    (fieldName)->
      this.sort_key = fieldName
      this.sort()

class RollFindr.Collections.NearbyLocationsCollection extends Backbone.Collection
  initialize: (options)->
    @location = options.location

  url: =>
    Routes.nearby_location_path(@location)

class RollFindr.Collections.RecentLocationsCollection extends Backbone.Collection
  initialize: (options)->
    @count = options.count

  url: =>
    Routes.recent_locations_path({count: @count})
