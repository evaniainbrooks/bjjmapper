class RollFindr.Models.User extends Backbone.Model
  defaults:
    preferences: {}
    name: null
    is_anonymous: true

  initialize: ->
    id = this.get('param') || this.get('id')
    students = @get('lineal_children')
    students = new RollFindr.Collections.StudentsCollection(students, {instructor_id: id})
    this.set('lineal_children', students)

    reviews = @get('reviews')
    reviews = new RollFindr.Collections.ReviewsCollection(reviews, {user_id: id})
    this.set('reviews', reviews)

    events = @get('events')
    events = new RollFindr.Collections.UserEventsCollection(events, {user_id: id})
    this.set('events', events)

  preference: (sym)->
    return @get('preferences')[sym]

  isAnonymous: ->
    @get('is_anonymous')

class RollFindr.Models.Instructor extends RollFindr.Models.User
  url: ->
    Routes.location_instructor_path(this.get('location_id'), this.get('id'))

class RollFindr.Models.Student extends RollFindr.Models.User
  url: ->
    Routes.user_student_path(this.get('instructor_id'), this.get('id'))

class RollFindr.Collections.UsersCollection extends Backbone.Collection
  model: RollFindr.Models.User
  url: '/users'
  sort_key: 'rank_sort_key'
  comparator:
    (item)->
      return item.get(this.sort_key)
  sortByField:
    (fieldName)->
      this.sort_key = fieldName
      this.sort()

class RollFindr.Collections.LocationInstructorsCollection extends RollFindr.Collections.UsersCollection
  model: RollFindr.Models.Instructor
  location_id: null,
  url: =>
    Routes.location_instructors_path(@location_id)
  initialize: (models, options)->
    _.extend(this, _.pick(options, "location_id"))

class RollFindr.Collections.TeamInstructorsCollection extends RollFindr.Collections.UsersCollection
  model: RollFindr.Models.Instructor
  team_id: null,
  url: =>
    Routes.team_instructors_path(@team_id)
  initialize: (models, options)->
    _.extend(this, _.pick(options, "team_id"))

class RollFindr.Collections.StudentsCollection extends RollFindr.Collections.UsersCollection
  model: RollFindr.Models.Student
  instructor_id: null,
  url: ->
    Routes.user_students_path(this.instructor_id)
  initialize: (models, options)->
    _.extend(this, _.pick(options, "instructor_id"))
