#= require backbone/views/create-event-view

class RollFindr.Views.CalendarView extends Backbone.View
  el: $('.scheduler')
  createEventView: null
  eventTemplate: JST['templates/event']
  initialize: (options)->
    _.bindAll(this, 'calendarSelected', 'calendarEventDrop', 'calendarEventRender', 'calendarEventClick')

    @editable = @$el.parents('.editable').hasClass('edit-mode')
    viewOptions = if @editable
      "agendaWeek,agendaDay"
    else
      "basicWeek,basicDay"

    locationId = @model.get('id')
    @$el.fullCalendar({
      events: Routes.location_events_path(locationId),
      eventDurationEditable: false,
      editable: @editable,
      height: 'auto',
      timezone: @model.get('timezone')
      selectable: @editable,
      select: this.calendarSelected,
      eventRender: this.calendarEventRender,
      #eventClick: this.calendarEventClick,
      eventDrop: this.calendarEventDrop,
      header: {
        left: 'prev,next today',
        center: 'title',
        right: viewOptions
      },
      defaultView: viewOptions.split(',')[0]
      minTime: "05:00:00"
      maxTime: "22:00:00"
    });

    @createEventView = new RollFindr.Views.CreateEventView()

  calendarEventClick: (event, jsEvent, view)->
    locationId = @model.get('id')
    window.location = Routes.location_event_path(locationId, event.id, { ref: 'cal' })
    return true

  calendarEventDrop: (event, delta, revertFunc)->
    locationId = @model.get('id')
    $.ajax({
      url: Routes.move_location_event_path(locationId, event.id),
      data: { deltams: delta.valueOf() },
      method: 'POST'
      error: (xhr, status, errorThrown)->
        toastr.error('Please try again later. If you think this is a bug, email us at info@bjjmapper.com', 'Failed to update event')
        revertFunc()
      success: ->
        toastr.success('Event has been updated')
    })

  calendarEventRender: (event, element, view)->
    element.addClass("event-#{event.type}")
    element.addClass("event-color-#{event.color_ordinal}")

    element.html(@eventTemplate({event: event}))

  calendarSelected: (start, end, event)->
    @createEventView.render(start, end)
