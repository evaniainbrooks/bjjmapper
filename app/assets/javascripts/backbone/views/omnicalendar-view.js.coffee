class RollFindr.Views.OmniCalendarView extends Backbone.View
  el: $('.scheduler')
  createEventView: null
  eventTemplate: JST['templates/omnievent']
  initialize: (options)->
    _.bindAll(this, 'initializeCalendarView', 'calendarSelected', 'calendarEventRender', 'calendarEventClick')

    @initializeCalendarView()

  initializeCalendarView: ()->
    viewOptions = "basicWeek,basicDay"

    @ids = @collection.pluck("id")

    @$el.fullCalendar({
      events: Routes.events_path({ids: @ids}),
      eventDurationEditable: false,
      editable: false,
      height: 'auto',
      timezone: @collection.first().get('timezone')
      selectable: false,
      select: this.calendarSelected,
      eventRender: this.calendarEventRender,
      eventClick: this.calendarEventClick,
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
    window.location = Routes.schedule_location_path(event.location, { ref: 'omnical' })
    return true

  calendarEventRender: (event, element, view)->
    colorIndex = @ids.indexOf(event.location) % 12

    element.addClass("event-#{event.type}")
    element.addClass("event-color-#{colorIndex}")
    element.addClass("event-omnicalendar")

    element.html(@eventTemplate({event: event}))

  calendarSelected: (start, end, event)->
    @createEventView.render(start, end)
