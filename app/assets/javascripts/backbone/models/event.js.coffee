class RollFindr.Models.Event extends Backbone.Model
  initialize: ->
    id = this.get('id')
    instructor = @get('instructor')
    instructor = new RollFindr.Models.User(instructor)
    @set('instructor', instructor)

  paramRoot: 'event'
  urlRoot: ->
    Routes.location_event_path(@location, @id)
  defaults:
    id: null
    title: null
    description: null
    location: null
    start: null
    end: null
    instructor: null
    recurrence: null
    type: null

