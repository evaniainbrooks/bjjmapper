#= require moment
#= require backbone/views/event-view-base

class RollFindr.Views.CreateEventView extends RollFindr.Views.EventViewBase
  el: $('.create-event-dialog')
  startPicker: null
  endPicker: null
  events: {
    'submit form': 'formSubmit'
    'keyup [name="event[title]"]': 'enableSubmit'
    'change [name="event[event_recurrence]"]': 'recurrenceChanged'
    'change [name="event[event_type]"]': 'eventTypeChanged'
  }
  enableSubmit: ->
    btn = @$('button[type="submit"]')
    if @hasTitle()
      btn.removeAttr('disabled')
    else
      btn.attr('disabled', true)

  hasTitle: ->
    @$('[name="event[title]"]').val().length > 0

  formSubmit: (e)->
    e.preventDefault()

    @$('select:hidden').prop('disabled', true)

    data = $(e.target).serializeArray()
    data.push({
      name: 'interval_start',
      value: @intervalStart
    })

    data.push({
      name: 'interval_end',
      value: @intervalEnd
    })

    method = $(e.target).attr('method')
    action = $(e.target).attr('action')
    $.ajax({
      type: method,
      url: action,
      data: $.param(data),
      success: (eventData)=>
        @$el.modal('hide')
        $('.scheduler').fullCalendar('addEventSource', eventData)
        toastr.success("Successfully added event to the calendar")
        window.location = eventData.redirect_to if eventData.redirect_to?
    })

  initialize: ->
    _.bindAll(this, 'enableSubmit', 'formSubmit', 'eventTypeChanged')
    RollFindr.Views.EventViewBase.prototype.setUiDefaults.call(this)
    RollFindr.Views.EventViewBase.prototype.initializePickers.call(this)

  showModalDialog: ->
    RollFindr.Views.EventViewBase.prototype.setUiDefaults.call(this)
    @$('[name="event[title]"]').val('')
    @$('select:hidden').removeProp('disabled')
    @$el.modal('show')

  render: (start, end, intervalStart, intervalEnd)->
    @eventStart = start
    @eventEnd = end

    @intervalStart = intervalStart
    @intervalEnd = intervalEnd

    @startPicker.data('DateTimePicker').setDate(@eventStart)
    @endPicker.data('DateTimePicker').setDate(@eventEnd)

    @showModalDialog()

  eventTypeChanged: (e)->
    @eventTypeName = @$(e.currentTarget).data('event-type-name')
    allEventTypeNames = _.map @$('[name="event[event_type]"]'), (o)->
      $(o).data('event-type-name')

    form = @$(e.currentTarget).parents('form')
    _.map allEventTypeNames, (className)->
      form.removeClass(className)
    form.addClass(@eventTypeName)

