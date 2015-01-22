
class RollFindr.Views.DirectionsDialogView extends Backbone.View
  directionsDisplay: new google.maps.DirectionsRenderer()
  directionsService: new google.maps.DirectionsService()
  events: {
    'keyup [name="address"]' : 'addressKeyUp'
    'click [type="submit"]' : 'getDirections'
    'click .use-current-location' : 'fillCurrentLocation'
  }
  initialize: (options)->
    _.bindAll(this, 'addressKeyUp', 'getDirections', 'fillCurrentLocation')

    @map = options.map

  addressKeyUp: (e)->
    if e.keyCode == 13
      @getDirections()

  fillCurrentLocation: (e)->
    geolocateSuccessCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      @$('[name="address"]').val(initialLocation.toString())
      @getDirections()

    geolocateFailedCallback = =>
      toastr.error('Could not pinpoint your location', 'Error')

    if navigator? && navigator.geolocation?
      navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback)
    else
      geolocateFailedCallback()

  getDirections: ->
    @$('.directions-panel').html('')

    startPoint = @$('[name="address"]').val()
    endPoint = @$el.data('end-address')
    travelMode = @$('[name="travel_mode"]:checked').val()

    @directionsService.route({
      origin: startPoint,
      destination: endPoint,
      travelMode: travelMode
    }, (result, status)=>
      if (status == google.maps.DirectionsStatus.OK)
        RollFindr.GlobalEvents.trigger('directions', {
          result: result,
          status: status
        })
      else
        toastr.error('Failed to request directions', 'Error')
    )

