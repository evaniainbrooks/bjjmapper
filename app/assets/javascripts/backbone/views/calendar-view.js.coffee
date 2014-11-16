#= require backbone/views/create-event-view

class RollFindr.Views.CalendarView extends Backbone.View
  el: $('.scheduler')
  createEventView: null
  eventTemplate: JST['templates/event']
  initialize: ->
    _.bindAll(this, 'calendarSelected', 'calendarEventRender', 'calendarEventClick')

    locationId = @model.get('id')
    @$el.fullCalendar({
      events: Routes.location_events_path(locationId),
      editable: true,
      selectable: true,
      select: this.calendarSelected,
      eventRender: this.calendarEventRender,
      eventClick: this.calendarEventClick,
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'agendaWeek,agendaDay'
      },
      defaultView: 'agendaDay'
    });

    @createEventView = new RollFindr.Views.CreateEventView()

  calendarEventClick: (event, jsEvent, view)->
    #alert('click')
    #event.preventDefault()
    return true

  calendarEventRender: (event, element, view)->
    instructor = $("[data-user-id='" + event.instructor + "']")
    eventColor = instructor.data('color-ordinal')
    element.addClass("event-#{event.type}")
    element.addClass("event-color-#{eventColor}")

    element.html(@eventTemplate({event: event}))

  calendarSelected: (start, end, event)->
    @createEventView.render(start, end)
