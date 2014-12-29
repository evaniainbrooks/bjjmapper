class RollFindr.Views.LocationWizardView extends Backbone.View
  el: $('.wizard')
  initialize: ->
    @$el.wizard()

    _.bindAll(this, 'enableNext', 'disableNext', 'initializeStep')

    @initializeStep()

  events: {
    'keyup [name="location[title]"]' : 'initializeStep'
    'keyup [name="location[postal_code]"]': 'initializeStep'
    'keyup [name="location[street]"]': 'initializeStep'
    'click .btn-next': 'disableNext'
    'click .
  }
  enableNext: ->
    @$('.btn-next').removeAttr('disabled')
    @$('.btn-next').attr('class', 'btn-success btn btn-next')

  disableNext: ->
    @$('.btn-next').attr('disabled', true)
    @$('.btn-next').attr('class', 'btn-default btn btn-next')

  initializeStep: ->
    if 1 == @currentStep()
      if @isTitleEntered()
        @enableNext()
      else
        @disableNext()
    else
      if @hasCoordinatesOrAddress()
        @enableNext()
      else
        @disableNext()

  hasCoordinatesOrAddress: ->
    hasCoords = @hasValue('input[name="location[coordinates]"]')
    hasPostalCode = @hasValue('input[name="location[postal_code]"]')
    hasStreet = @hasValue('input[name="location[street]"]')

    return hasCoords || (hasPostalCode && hasStreet)

  currentStep: ->
    selectedItem = @$el.wizard('selectedItem')
    return selectedItem.step if selectedItem?

  isTitleEntered: ->
    @hasValue('input[name="location[title]"]')

  hasValue: (selector)->
    elem = @$(selector)
    elem.length > 0 && elem.val().length > 0

