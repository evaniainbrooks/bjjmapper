#= require backbone/views/map/map_view
#= require backbone/models/map

class RollFindr.Views.EventVenueWizardView extends Backbone.View
  el: $('.page')
  createLocationView: null
  nearbyLocationsView: null
  map: null
  initialize: (options)->
    _.bindAll(this,
      'addressChanged',
      'addressValueChanged',
      'fetchNearbyLocations',
      'fullAddressKeyUp',
      'initializeMapView',
      'searchAddress',
      'useVenue',
      'useAddress'
    )

    @createEventView = new RollFindr.Views.CreateEventView(el: $('.create-event-dialog'))
    @enableSubmit()

  events: {
    'change #address_options': 'addressChanged'
    'change [name="location[street]"]': 'addressValueChanged'
    'keyup [name="location[street]"]': 'addressValueChanged'
    'change [name="location[postal_code]"]': 'addressValueChanged'
    'keyup [name="location[postal_code]"]': 'addressValueChanged'
    'keyup #full_address': 'fullAddressKeyUp'
    'click [data-address-search]': 'searchAddress'
    'click .use-address': 'useAddress'
    'click .use-venue': 'useVenue'
  }

  enableSubmit: ->
    btn = @$('button[type="submit"]')
    if @hasAddress() && @createEventView.enableSubmit()
      btn.removeAttr('disabled')
    else
      btn.attr('disabled', true)

  addressValueChanged: ->
    @enableSubmit()

  hasAddress: ->
    hasPostalCode = @hasValue('input[name="location[postal_code]"]')
    hasStreet = @hasValue('input[name="location[street]"]')

    hasLocationId = @hasValue('input[name="location_id"]')

    return (hasPostalCode && hasStreet) || hasLocationId

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
    @enableSubmit()

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
          .prop('disabled', true)
          .prop('class', 'fa fa-2x fa-refresh fa-spin')

      complete: =>
        @$('.fa-refresh')
          .removeProp('disabled')
          .prop('class', 'fa fa-2x fa-search')

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

        $('html, body').animate({
          scrollTop: $('[name="addr-more"]').offset().top - $('.navbar').height()
        }, 1000)
    })

  useVenue: (e)->
    venueId = $(e.currentTarget).data('id')
    @$('[name="location_id"]').removeProp('disabled')
    @$('[name="location_id"]').val(venueId)
    @$('.editable').removeClass('edit-mode')
    @enableSubmit()

  useAddress: ->
    @$('[name="location_id"]').prop('disabled', true)
    @$('.editable').removeClass('edit-mode')
    @enableSubmit()

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
    @nearbyLocationsView = new RollFindr.Views.LocationNearbyView({ model: model, count: 3, template: 'templates/locations/nearby-event-venue' })
