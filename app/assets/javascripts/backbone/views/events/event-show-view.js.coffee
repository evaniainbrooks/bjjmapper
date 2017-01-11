#= require moment
#= require backbone/views/events/event-view-base

class RollFindr.Views.EventShowView extends RollFindr.Views.EventViewBase
  el: $('.container')
  template: JST['templates/locations/instructor']
  events: {
    'change [name="event[event_recurrence]"]': 'recurrenceChanged'
  }
  initialize: ->
    @render()

  render: ->
    RollFindr.Views.EventViewBase.prototype.setUiDefaults.call(this, @model.get('recurrence_type'))
    RollFindr.Views.EventViewBase.prototype.initializePickers.call(this, @model.get('start'), @model.get('end'))

    @showInstructor()
    @selectDaysFromModel()

  showInstructor: ->
    instructor = @model.get('instructor')
    if instructor.get('name')?
      elem = @template({instructor: instructor.toJSON()})
      @$('.instructors .items').html(elem)

  selectDaysFromModel: ->
    _.each @model.get('recurrence_days'), (e, i)->
      @$('[value=' + e + ']').attr('checked', true)
      @$('[value=' + e + ']').parent().addClass('active')

