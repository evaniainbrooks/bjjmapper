class RollFindr.Views.ClaimLocationDialogView extends Backbone.View
  events: {
    'change [name="email"]': 'enableSubmit'
    'keyup [name="email"]': 'enableSubmit'
  }

  initialize: ->
    _.bindAll(this, 'enableSubmit')
    @enableSubmit()

  hasValue: (selector)->
    elem = @$(selector)
    elem.length > 0 && elem.val().length > 0

  enableSubmit: ->
    if @hasValue('[name="email"]')
      @$('[type="submit"]').removeAttr('disabled')
    else
      @$('[type="submit"]').attr('disabled', true)

