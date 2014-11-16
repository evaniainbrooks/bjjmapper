class RollFindr.Views.CreateEventView extends Backbone.View
  el: $('.add-event-dialog'),
  events: {
    'submit form': 'formSubmit'
  }
  formSubmit: (e)->
    e.preventDefault()

    @start.hours(@getStartHours())
    @start.minutes(@getStartMinutes())

    @end.hours(@getEndHours())
    @end.minutes(@getEndMinutes())

    data = {}
    data['event[starting]'] = @start.unix()
    data['event[ending]'] = @end.unix()
    _.each ['title', 'description', 'instructor', 'recurrence'], (k)->
      data["event[#{k}]"] = $("[name='event[#{k}]']", e.target).val()

    method = $(e.target).attr('method')
    action = $(e.target).attr('action')
    $.ajax({
      type: method,
      url: action,
      data: data,
      success: =>
        @$el.modal('hide')
    })

  initialize: ->
    _.bindAll(this, 'formSubmit')

  render: (start, end)->
    @start = start
    @end = end

    @$('#date_start_hours').val(@hourForCalendar(start.hours()))
    @$('#date_start_am_pm').val(@amPm(start.hours()))
    @$('#date_start_minutes').val(@valueForCalendar(start.minutes()))

    @$('#date_end_hours').val(@hourForCalendar(end.hours()))
    @$('#date_end_am_pm').val(@amPm(end.hours()))
    @$('#date_end_minutes').val(@valueForCalendar(end.minutes()))

    @$el.modal('show')

  getStartHours: ->
    hours = parseInt(@$('#date_start_hours').val(), 10)
    amPm = @$('#date_start_am_pm').val()
    hours += 12 if amPm == 'pm'

  getStartMinutes: ->
    parseInt(@$('#date_start_minutes').val(), 10)

  getEndHours: ->
    hours = parseInt(@$('#date_end_hours').val(), 10)
    amPm = @$('#date_end_am_pm').val()
    hours += 12 if amPm == 'pm'

  getEndMinutes: ->
    parseInt(@$('#date_end_minutes').val(), 10)

  amPm: (v)->
    if v >= 12 then 'pm' else 'am'

  hourForCalendar: (v)->
    hour = if v > 12
      v - 12
    else if v == 0
      12
    else
      v

    return @valueForCalendar(hour)

  valueForCalendar: (v)->
    return @pad2(v)

  pad2: (n)->
    if n < 10 then "0" + n else n
