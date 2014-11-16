class RollFindr.Models.Event extends Backbone.Model
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

