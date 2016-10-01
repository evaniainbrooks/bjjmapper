#= require backbone/views/create-event-view

class RollFindr.Views.LocationCalendarView extends Backbone.View
  el: $('.scheduler-container')
  createEventView: null
  eventTemplate: JST['templates/event']
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

    @editable = options.editable

    @initializeCalendarView(@editable)

  intervalStart: ->
    return @$('.scheduler').fullCalendar('getView').intervalStart

  intervalEnd: ->
    return @$('.scheduler').fullCalendar('getView').intervalEnd

  initializeCalendarView: (editable)->
    viewOptions = if editable
      "agendaWeek,agendaDay"
    else
      "basicWeek,basicDay"

    @$el.html('<div class="scheduler"></div>')

    locationId = @model.get('id')
    @$('.scheduler').fullCalendar({
      events: Routes.location_events_path(locationId),
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
    $.ajax({
      url: Routes.move_location_event_path(locationId, event.id)
      data: { deltams: delta.valueOf() }
      method: 'POST'
      error: (xhr, status, errorThrown)->
        toastr.error('Please try again later. If you think this is a bug, email us at info@bjjmapper.com', 'Failed to update event')
        revertFunc()
      success: =>
        toastr.success('Event has been updated')
    })

  calendarEventRender: (event, element, view)->
    element.addClass("event-#{event.event_type_name}")
    element.addClass("event-color-#{event.color_ordinal}")
    element.addClass("event-editable") if @editable

    element.html(@eventTemplate({event: event}))

  calendarSelected: (start, end, event)->
    @createEventView.render(start, end, @intervalStart(), @intervalEnd())

