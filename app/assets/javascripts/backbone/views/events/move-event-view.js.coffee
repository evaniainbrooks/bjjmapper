class RollFindr.Views.MoveEventView extends RollFindr.Views.EventViewBase
  el: $('.move-event-modal')
  events: {
    'change [name="recurrence_action"]': 'actionChanged'
  }

  initialize: ->
    _.bindAll(this, 'actionChanged')

  render: (moveEventFunction)->
    @moveEventFunction = moveEventFunction
    @$el.modal('show')

  actionChanged: (e)->
    val = $(e.currentTarget).val()
    alert(val)
    @$el.modal('hide')
    @moveEventFunction(val)



