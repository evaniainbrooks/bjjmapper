class RollFindr.Models.User extends Backbone.Model
  defaults:
    name: null
    role: 'anonymous'

  initialize: ->
    id = this.get('id')
    students = @get('lineal_children')
    students = new RollFindr.Collections.StudentsCollection(students, {instructor_id: id})
    this.set('lineal_children', students)

    reviews = @get('reviews')
    reviews = new RollFindr.Collections.ReviewsCollection(reviews, {user_id: id})
    this.set('reviews', reviews)

  isAnonymous: ->
    @get('role') == 'anonymous'

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

class RollFindr.Collections.InstructorsCollection extends RollFindr.Collections.UsersCollection
  model: RollFindr.Models.Instructor
  location_id: null,
  url: =>
    Routes.location_instructors_path(@location_id)
  initialize: (models, options)->
    _.extend(this, _.pick(options, "location_id"))

class RollFindr.Collections.StudentsCollection extends RollFindr.Collections.UsersCollection
  model: RollFindr.Models.Student
  instructor_id: null,
  url: ->
    Routes.user_students_path(this.instructor_id)
  initialize: (models, options)->
    _.extend(this, _.pick(options, "instructor_id"))
