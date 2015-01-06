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
    'click .btn-next': 'initializeStep'
    'click [data-address-search]': 'searchAddress'
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
    hasPostalCode = @hasValue('input[name="location[postal_code]"]')
    hasStreet = @hasValue('input[name="location[street]"]')

    return (hasPostalCode && hasStreet)

  currentStep: ->
    selectedItem = @$el.wizard('selectedItem')
    return selectedItem.step if selectedItem?

  isTitleEntered: ->
    @hasValue('input[name="location[title]"]', 2)

  hasValue: (selector, cmplength)->
    cmplength = 0 if undefined == cmplength

    elem = @$(selector)
    elem.length > 0 && elem.val().length > cmplength

  searchAddress: ->
    $.ajax({
      url: Routes.geocode_path(),
      data: {
        query: $('#full_address').val()
      }
      method: 'GET'
      success: (result)=>
        @$('.editable').addClass('edit-mode')
        @$('#address_options')
          .html($('<option></option>')
          .attr('value', result.address)
          .text(result.address))

        _.each(['street', 'city', 'postal_code', 'state', 'country'], (i)=>
          @$("[name='location[#{i}]']").val(result[i])
        )

        @enableNext()
    })

