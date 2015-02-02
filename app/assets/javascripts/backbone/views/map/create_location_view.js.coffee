class RollFindr.Views.MapCreateLocationView extends Backbone.View
  el: $('.wrapper')
  template: JST['templates/create_location_button']
  events: {
    'click .add-academy-quick': 'addAcademyQuickClicked'
    'click .add-academy-quick-geo': 'addAcademyQuickGeoClicked'
  }
  initialize: (options)->
    _.bindAll(this,
      'addAcademyQuickClicked',
      'addAcademyQuickGeoClicked')

    @map = options.map
    @render()

  addAcademyQuickClicked: (event)->
    mixpanel.track('clickAddAcademy', { quick: true })

    return false unless @checkLoggedInOrShowModal()

    @$el.addClass('map-edit-mode')
    @mapClickHandler = google.maps.event.addListener @map, 'click', (event)=>
      mixpanel.track('clickMap', {
        lat: event.latLng.lat(),
        lng: event.latLng.lng()
      })

      @showQuickCreateModalForCoords(event.latLng.lat(), event.latLng.lng())

  addAcademyQuickGeoClicked: (event)->
    mixpanel.track('clickAddAcademyQuickGeo', { quick: true, geo: true })

    return false unless @checkLoggedInOrShowModal()

    geolocateSuccessCallback = (position)=>
      @showQuickCreateModalForCoords(position.coords.latitude, position.coords.longitude)

    geolocateFailedCallback = ->
      toastr.error('Could not pinpoint your location', 'Error')

    navigator.geolocation.getCurrentPosition(geolocateSuccessCallback, geolocateFailedCallback) if navigator? && navigator.geolocation?

  checkLoggedInOrShowModal: ->
    if RollFindr.CurrentUser.isAnonymous()
      $('.login-modal').modal('show')
      false
    else
      true

  showQuickCreateModalForCoords: (lat, lng)->
    $('.coordinates', '.create-location-dialog').val(JSON.stringify([lng, lat]))
    $('.create-location-quick-dialog').modal('show')

  render: ->
    btn = @template()
    @map.controls[google.maps.ControlPosition.TOP_LEFT].push($(btn)[0])
