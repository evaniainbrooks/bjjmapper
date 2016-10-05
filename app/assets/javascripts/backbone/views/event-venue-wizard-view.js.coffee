#= require backbone/views/map/map_view
#= require backbone/models/map

class RollFindr.Views.EventVenueWizardView extends Backbone.View
  el: $('.wizard')
  createLocationView: null
  nearbyLocationsView: null
  map: null
  initialize: (options)->
    @$el.wizard()

    _.bindAll(this,
      'addressChanged',
      'addressValueChanged',
      'fetchNearbyLocations',
      'fullAddressKeyUp',
      'initializeMapView',
      'nextClicked',
      'prevClicked',
      'searchAddress',
      'titleChanged')

    @$('.btn-next')
      .attr('type', 'button')
      .attr('disabled', true)

    @$('.btn-prev').attr('type', 'button')

    @createEventView = new RollFindr.Views.CreateEventView(el: $('.create-event-dialog'))

  events: {
    'change #address_options': 'addressChanged'
    'change [name="location[street]"]': 'addressValueChanged'
    'keyup [name="location[street]"]': 'addressValueChanged'
    'change [name="location[postal_code]"]': 'addressValueChanged'
    'keyup [name="location[postal_code]"]': 'addressValueChanged'
    'change [name="location[title]"]' : 'titleChanged'
    'keyup [name="location[title]"]' : 'titleChanged'
    'keyup #full_address': 'fullAddressKeyUp'
    'click [data-address-search]': 'searchAddress'
    'click .btn-next': 'nextClicked'
    'click .btn-prev': 'prevClicked'
  }

  addressValueChanged: ->
    @setNextDisabled( !@hasAddress() )

  prevClicked: ->
    @$('.btn-next')
      .removeAttr('type')
      .attr('type', 'button')
      .removeClass('btn-success')
    @resetActionButtons()

  resetActionButtons: ->
    switch @currentStep()
      when 1
        @titleChanged() && @addressValueChanged()
      when 2
        setTimeout =>
          @$('.btn-next')
            .attr('type', 'submit')
            .addClass('btn-success')
        , 50

  nextClicked: ->
    if 'submit' != @$('.btn-next').attr('type')
      @resetActionButtons()

  setNextDisabled: (state)->
    if state
      @$('.btn-next').attr('disabled', true)
    else
      @$('.btn-next').removeAttr('disabled')

  titleChanged: ->
    @setNextDisabled( !@isTitleEntered() )

  hasAddress: ->
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

  addressChanged: (e)->
    _.each ['street', 'city', 'postal_code', 'state', 'country'], (i)=>
      value = $('option:selected', e.currentTarget).data(i)
      @$("[name='location[#{i}]']").val(value)

    lat = $('option:selected', e.currentTarget).data('lat')
    lng = $('option:selected', e.currentTarget).data('lng')
    title = $('option:selected', e.currentTarget).data('value')
    @initializeMapView(title, lat, lng)
    @fetchNearbyLocations(lat, lng)
    @setNextDisabled( !@hasAddress() )

  fullAddressKeyUp: (e)->
    if e.keyCode == 13
      @searchAddress()

  searchAddress: ->
    $.ajax({
      url: Routes.geocoder_path(),
      data: {
        query: $('#full_address').val()
      }
      beforeSend: =>
        @$('.fa-search')
          .attr('disabled', true)
          .attr('class', 'fa fa-2x fa-refresh fa-spin')

      complete: =>
        @$('.fa-refresh')
          .attr('class', 'fa fa-2x fa-search')
          .removeAttr('disabled')

      method: 'GET'
      success: (results)=>
        @$('.editable').addClass('edit-mode')
        @$('#address_options').html('')
        _.each results, (result)=>
          @$('#address_options')
            .append($('<option></option>')
            .attr('value', result.address)
            .data('street', result.street)
            .data('city', result.city)
            .data('postal_code', result.postal_code)
            .data('state', result.state)
            .data('country', result.country)
            .data('lat', result.lat)
            .data('lng', result.lng)
            .text(result.address))

        _.each ['street', 'city', 'postal_code', 'state', 'country'], (i)=>
          @$("[name='location[#{i}]']").val(results[0][i])

        @fetchNearbyLocations(results[0]['lat'], results[0]['lng'])
        @initializeMapView(results[0]['address'], results[0]['lat'], results[0]['lng'])
        @setNextDisabled( !@hasAddress() )

    })

  initializeMapView: (title, lat, lng)->
    center = new google.maps.LatLng(lat, lng)
    mapOptions = {
      zoom: 12
      minZoom: 12
      mapTypeId: google.maps.MapTypeId.ROADMAP
      center: center
    }
    mapCanvas = @$('.map-canvas')[0]
    @map = new google.maps.Map(mapCanvas, mapOptions)

    marker = new google.maps.Marker(
      map: @map
      title: title
      position: center
    )

  fetchNearbyLocations: (lat, lng)->
    model = new RollFindr.Models.Location({
      id: null
      coordinates: [lat, lng]
    })
    @nearbyLocationsView = new RollFindr.Views.LocationNearbyView({ model: model })
