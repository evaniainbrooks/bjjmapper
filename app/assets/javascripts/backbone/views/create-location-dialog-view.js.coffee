class RollFindr.Views.CreateLocationDialogView extends Backbone.View
  events: {
    'change [name="location[team_id]"]': 'changeTeam'
    'keyup [name="location[title]"]': 'enableSubmit'
    'keyup [name="location[postal_code]"]': 'enableSubmit'
    'keyup [name="location[street]"]': 'enableSubmit'
  }

  initialize: ->
    _.bindAll(this, 'changeTeam', 'enableSubmit')

  changeTeam: (e)->
    teamImg = $('option:selected', e.currentTarget).data('img-src')
    imgElem = @$('.edit-image')
    imgElem.attr('src', if teamImg.length > 0 then teamImg else imgElem.data('default-src'))

    @enableSubmit()

  isNameEntered: ->
    @$('input[name="location[title]"]').val().length > 0

  hasCoordinatesOrAddress: ->
    hasCoords = @hasValue('input[name="location[coordinates]"]')
    hasPostalCode = @hasValue('input[name="location[postal_code]"]')
    hasStreet = @hasValue('input[name="location[street]"]')

    return hasCoords || (hasPostalCode && hasStreet)

  hasValue: (selector)->
    elem = @$(selector)
    elem.length > 0 && elem.val().length > 0

  enableSubmit: ->
    if @isNameEntered() && @hasCoordinatesOrAddress()
      @$('[type="submit"]').removeAttr('disabled')
