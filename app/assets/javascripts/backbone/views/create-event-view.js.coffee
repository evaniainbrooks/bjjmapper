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
    'change [name="event[organization]"]': 'enableSubmit'
    'change [name="event[instructor]"]':  'enableSubmit'
  }

  enableSubmit: ->
    btn = @$('button[type="submit"]')
    if @hasTitle() && @hasInstructorOrOrganization() && @hasStartingEnding()
      btn.removeAttr('disabled')
      return true
    else
      btn.attr('disabled', true)
      return false

  hasInstructorOrOrganization: ->
    if @eventType == RollFindr.Models.Event.EVENT_TYPE_TOURNAMENT && @$('[name="event[organization]"]').val().length > 0
      return true
    else if @eventType == RollFindr.Models.Event.EVENT_TYPE_SEMINAR && @$('[name="event[instructor]"]:visible').val().length > 0
      return true
    else if @eventType == RollFindr.Models.Event.EVENT_TYPE_CLASS
      return true
    else
      return false

  hasTitle: ->
    title = @$('[name="event[title]"]')
    return title.val() && title.val().length > 0

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
        if eventData.redirect_to?
          window.location = eventData.redirect_to
        else
          $('.scheduler').fullCalendar('addEventSource', eventData)
          toastr.success("Successfully added event to the calendar")
    })

  initialize: ->
    _.bindAll(this, 'enableSubmit', 'formSubmit', 'eventTypeChanged')
    RollFindr.Views.EventViewBase.prototype.setUiDefaults.call(this)
    RollFindr.Views.EventViewBase.prototype.initializePickers.call(this)

    @eventType = parseInt(@$('[name="event[event_type]"]').val(), 10)
    @enableSubmit()

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
    @eventType = parseInt(@$(e.currentTarget).val(), 10)
    allEventTypeNames = _.map @$('[name="event[event_type]"]'), (o)->
      $(o).data('event-type-name')

    form = @$(e.currentTarget).parents('form')
    _.map allEventTypeNames, (className)->
      form.removeClass(className)
    form.addClass(@eventTypeName)

    @enableSubmit()
