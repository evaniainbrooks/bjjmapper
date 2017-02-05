class RollFindr.Views.DirectionsDialogView extends Backbone.View
  directionsDisplay: new google.maps.DirectionsRenderer()
  directionsService: new google.maps.DirectionsService()
  events: {
    'keyup [name="address"]' : 'addressKeyUp'
    'click [type="submit"]' : 'getDirections'
    'click .use-current-location' : 'fillCurrentLocation'
  }
  template: JST['templates/directions_dialog']
  initialize: (options)->
    _.bindAll(this, 'addressKeyUp', 'getDirections', 'fillCurrentLocation')

    @$el.html(@template({location: @model.toJSON()}))

    $('.directions-dialog').on 'shown.bs.modal', ->
      $('.directions-dialog [name="address"]').focus()
    $('.directions-dialog').modal('show')

  addressKeyUp: (e)->
    @getDirections() if e.keyCode == 13

  fillCurrentLocation: (e)->
    geolocateSuccessCallback = (position)=>
      initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      @$('[name="address"]').val(initialLocation.toString())
      @getDirections(initialLocation)

    geolocateFailedCallback = =>
      toastr.error('Could not pinpoint your location', 'Error')

    if navigator? && navigator.geolocation?
      navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback)
    else
      geolocateFailedCallback()

  getDirections: (startPoint)->
    startPoint = @$('[name="address"]').val() unless startPoint?
    endPointLat = @$('.directions-dialog').data('lat')
    endPointLng = @$('.directions-dialog').data('lng')
    endPoint = new google.maps.LatLng(endPointLat, endPointLng)

    travelMode = @$('[name="travel_mode"]:checked').val()

    @directionsService.route({
      origin: startPoint,
      destination: endPoint,
      travelMode: travelMode
    }, (result, status)=>
      if (status == google.maps.DirectionsStatus.OK)
        $('.directions-dialog').modal('hide')
        RollFindr.GlobalEvents.trigger('directions', {
          result: result,
          status: status
        })

      else if (status == google.maps.DirectionsStatus.ZERO_RESULTS)
        toastr.error('There is no route from your location to the chosen destination', 'Error')
      else
        toastr.error('Failed to request directions', 'Error')
    )

