#= require moment

class RollFindr.Views.CreateEventView extends Backbone.View
  el: $('.add-event-dialog')
  startPicker: null
  endPicker: null
  events: {
    'submit form': 'formSubmit'
    'keyup [name="event[title]"]': 'enableSubmit'
    'change [name="event[event_recurrence]"]': 'recurrenceChanged'
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

    data = $(e.target).serialize()
    method = $(e.target).attr('method')
    action = $(e.target).attr('action')
    $.ajax({
      type: method,
      url: action,
      data: data,
      success: (eventData)=>
        @$el.modal('hide')
        $('.scheduler').fullCalendar('addEventSource', [eventData])
        toastr.success("Successfully added event to the calendar")
    })

  initialize: ->
    _.bindAll(this, 'enableSubmit', 'formSubmit')
    @initializePickers()
    @setUiDefaults()

  setUiDefaults: ->
    $('[name="event[event_recurrence]"]').val("0")
    $('[name="event[weekly_recurrence_days]"]').removeAttr('checked')
    $('.week-recurrence').hide()

  showModalDialog: ->
    @setUiDefaults()
    @$el.modal('show')

  initializePickers: ->
    icons = {
      time: "fa fa-clock-o",
      date: "fa fa-calendar",
      up: "fa fa-arrow-up",
      down: "fa fa-arrow-down"
    }

    formatIso8601 = "YYYY-MM-DDTHH:mm:ss"

    $('.pick-time').datetimepicker({
      pickTime: true
      sideBySide: true
      useSeconds: false
      useCurrent: false
      minuteStepping: 15
      icons: icons
      format: formatIso8601
    })

    @startPicker = $('.pick-time.start')
    @endPicker = $('.pick-time.end')
    @startPicker.on "dp.change", (e)=>
      @endPicker.data("DateTimePicker").setMinDate(e.date)

    @endPicker.on "dp.change", (e)=>
      @startPicker.data("DateTimePicker").setMaxDate(e.date)

  render: (start, end)->
    @start = start
    @end = end

    @startPicker.data('DateTimePicker').setDate(@start)
    @endPicker.data('DateTimePicker').setDate(@end)

    @showModalDialog()

  recurrenceChanged: (e)->
    recurrence = $(e.currentTarget).val()
    if parseInt(recurrence, 10) > 2
      $('.week-recurrence').show()
      day = moment(@startPicker.data('DateTimePicker').getDate()).day()
      @$('[value=' + day + ']').attr('checked', true)
      @$('[name="event[weekly_recurrence_days]"]').each (i, o)->
        if parseInt($(o).val(), 10) == day
          $(o).attr('checked', true)
          $(o).parent().addClass('active')
        else
          $(o).removeAttr('checked')
          $(o).parent().removeClass('active')
    else
      $('.week-recurrence').hide()
