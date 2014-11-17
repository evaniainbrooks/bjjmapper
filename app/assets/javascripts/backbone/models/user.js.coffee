class RollFindr.Models.User extends Backbone.Model
  defaults:
    name: null
    role: 'anonymous'

  isAnonymous: ->
    @get('role') == 'anonymous'

class RollFindr.Models.Instructor extends RollFindr.Models.User
  url: ->
    Routes.location_instructor_path(this.get('location_id'), this.get('id'))

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

class RollFindr.Collections.InstructorsCollection extends RollFindr.Collections.UsersCollection
  model: RollFindr.Models.Instructor
  location_id: null,
  url: ->
    Routes.location_instructors_path(this.location_id)
  initialize: (models, options)->
  #  Backbone.Collection.prototype.initialize.apply(this, arguments)
    _.extend(this, _.pick(options, "location_id"))

