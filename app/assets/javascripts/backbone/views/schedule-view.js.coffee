#= require backbone/views/create-event-view
#= require backbone/views/move-event-view

class RollFindr.Views.ScheduleView extends Backbone.View
  createEventView: null
  defaultDate: new Date()
  el: $('.scheduler-container')
  eventTemplate: JST['templates/event']
  moveEventView: null
  initialize: (options)->
    _.bindAll this,
      'initializeCalendarView',
      'intervalStart',
      'intervalEnd',
      'calendarSelected',
      'calendarEventDrop',
      'calendarEventRender',
      'calendarEventClick'

    RollFindr.GlobalEvents.on('editing', @initializeCalendarView)

    @createEventView = new RollFindr.Views.CreateEventView()
    @moveEventView = new RollFindr.Views.MoveEventView()

    @editable = options.editable
    @defaultDate = options.starting if options.starting? && options.starting.length > 0

    @initializeCalendarView(@editable)

  intervalStart: ->
    return @$('.scheduler').fullCalendar('getView').intervalStart

  intervalEnd: ->
    return @$('.scheduler').fullCalendar('getView').intervalEnd

  initializeCalendarView: (editable)->
    viewOptions = if editable
      "agendaWeek,agendaDay"
    else
      "basicWeek,basicDay,month"

    @$el.html('<div class="scheduler"></div>')

    locationId = @model.get('id')
    #TODO: Fix EventsCollection to determine this
    eventsPath = @model.get('events').url()
    @$('.scheduler').fullCalendar({
      defaultDate: @defaultDate
      events: eventsPath,
      eventDurationEditable: false,
      editable: editable,
      height: 'auto',
      timezone: @model.get('timezone')
      selectable: editable,
      select: this.calendarSelected,
      eventRender: this.calendarEventRender,
      eventClick: this.calendarEventClick,
      eventDrop: this.calendarEventDrop,
      header: {
        left: 'prev,next today',
        center: 'title',
        right: viewOptions
      },
      defaultView: viewOptions.split(',')[0]
      minTime: "05:00:00"
      maxTime: "22:00:00"
    })

  calendarEventClick: (event, jsEvent, view)->
    locationId = @model.get('id')
    eventId = event.id

    window.location = Routes.location_event_path(locationId, eventId)
    return true

  calendarEventDrop: (event, delta, revertFunc)->
    locationId = @model.get('id')
    moveEventFunction = (recurrenceAction)=>
      locationId = @model.get('id')
      $.ajax({
        url: Routes.move_location_event_path(locationId, event.id)
        data: {
          deltams: delta.valueOf()
          recurrence_action: recurrenceAction
          event: {
            id: event.id
            starting: event.starting
            ending: event.ending
          }
        }
        method: 'POST'
        error: (xhr, status, errorThrown)->
          toastr.error('Please try again later. If you think this is a bug, email us at info@bjjmapper.com', 'Failed to update event')
          revertFunc()
        success: ->
          toastr.success('Event has been updated')
      })

    #if event.recurring
    #  @moveEventView.render(moveEventFunction)
    #  return
    #else
    moveEventFunction()

  calendarEventRender: (event, element, view)->
    element.addClass("event-#{event.event_type_name}")
    element.addClass("event-color-#{event.color_ordinal}")
    element.addClass("event-editable") if @editable

    element.html(@eventTemplate({event: event}))

  calendarSelected: (start, end, event)->
    @createEventView.render(start, end, @intervalStart(), @intervalEnd())

