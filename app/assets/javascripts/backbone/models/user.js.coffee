class RollFindr.Models.User extends Backbone.Model

class RollFindr.Models.Instructor extends RollFindr.Models.User
  location_id: null,
  url: ->
    Routes.instructors_location_path(this.location_id)
  initialize: (options)->
    _.extend(this, _.pick(options, "location_id"))


class RollFindr.Collections.UsersCollection extends Backbone.Collection
  model: RollFindr.Models.User
  url: '/users'
  sort_key: 'id'
  comparator:
    (item)->
      return item.get(this.sort_key)
  sortByField:
    (fieldName)->
      this.sort_key = fieldName
      this.sort()

