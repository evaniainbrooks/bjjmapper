#= require moment

class RollFindr.Views.EventViewBase extends Backbone.View
  startPicker: null
  endPicker: null

  setUiDefaults: (recurrence)->
    recurrence = 0 unless recurrence?

    $('[name="event[event_recurrence]"]').val(recurrence)
    $('[name="event[weekly_recurrence_days][]"]').removeAttr('checked')
    $('[name="event[weekly_recurrence_days][]"]').parent().removeClass('active')
    $('.week-recurrence').hide() unless recurrence > 2

  initializePickers: (start, end)->
    icons = {
      time: "fa fa-clock-o",
      date: "fa fa-calendar",
      up: "fa fa-arrow-up",
      down: "fa fa-arrow-down"
    }

    formatIso8601 = "YYYY-MM-DDTHH:mm:ss"
    formatNoTime = "DD/MM/YYYY"

    $('.pick-time').each ->
      pickTime = $(this).data('pick-time')
      format = if pickTime then formatIso8601 else formatNoTime
      $(this).datetimepicker({
        pickTime: pickTime
        sideBySide: pickTime
        useSeconds: false
        useCurrent: false
        minuteStepping: 15
        icons: icons
        format: format 
      })

    @startPicker = $('.pick-time.start')
    @endPicker = $('.pick-time.end')

    @startPicker.data('DateTimePicker').setDate(start) if start?
    @endPicker.data('DateTimePicker').setDate(end) if end?

    @startPicker.on "dp.change", (e)=>
      @endPicker.data("DateTimePicker").setMinDate(e.date)

    @endPicker.on "dp.change", (e)=>
      @startPicker.data("DateTimePicker").setMaxDate(e.date)

  hasStartingEnding: ->
    $('[name="event[starting]"]').val() && $('[name="event[ending]"]').val() && $('[name="event[starting]"]').val().length > 0 && $('[name="event[ending]"]').val().length > 0

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
