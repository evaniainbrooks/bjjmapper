#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/map
#= require backbone/views/map/map_view
#= require toastr

describe 'Views.MapView', ->
  viewModel = new RollFindr.Models.Map({"zoom":12,"center":[80.0,80.0],"geolocate":1,"locations":[]})
  view = null
  searchSpy = null
  geolocateSpy = null
  renderSpy = null

  setupSpies = ->
    searchSpy = sinon.spy(RollFindr.Views.MapView.prototype, 'search')
    geolocateSpy = sinon.spy(RollFindr.Views.MapView.prototype, 'setCenterGeolocate')
    renderSpy = sinon.spy(RollFindr.Views.MapView.prototype, 'render')

  setupDom = ->
    $('body').addHtml('div', {'class': 'map-canvas'})

  beforeEach ->
    this.server = sinon.fakeServer.create()
    emptyResponse = [
      204,
      {'Content-Type': 'application/json'},
      '{}'
    ]
    this.server.respondWith(
      'GET',
      '/teams',
      emptyResponse
    )
    this.server.respondWith(
      'GET',
      '/locations/search',
      emptyResponse
    )
    stubGoogleMapsApi()
    setupSpies()
    setupDom()

    view = new RollFindr.Views.MapView({model: viewModel, el: $('body')})

  afterEach ->
    this.server.restore()
    RollFindr.Views.MapView.prototype.search.restore()
    if RollFindr.Views.MapView.prototype.setCenterGeolocate.restore?
      RollFindr.Views.MapView.prototype.setCenterGeolocate.restore()
    RollFindr.Views.MapView.prototype.render.restore()

  it 'listens to global search event', ->
    RollFindr.GlobalEvents.trigger('search', {})
    sinon.assert.called(searchSpy)

  it 'listens to global geolocate event', ->
    stubCurrentUser()
    RollFindr.GlobalEvents.trigger('geolocate', {})
    sinon.assert.called(geolocateSpy)

  it 'renders itself when the location list is updated', ->
    viewModel.get('locations').trigger('sync')
    sinon.assert.called(renderSpy)

  describe 'geolocation', ->
    mapMock = null
    GEOLOCATE_RESULT = {
      coords:
        latitude: 81.0
        longitude: 81.0
    }

    beforeEach ->
      stubCurrentUser()

      RollFindr.Views.MapView.prototype.setCenterGeolocate.restore()
      mapMock = sinon.mock(view.map)
      mapMock.expects('setCenter').once()
      mapMock.expects('getCenter').returns(
        new google.maps.LatLng(
          RollFindr.CurrentUser.get('lat'),
          RollFindr.CurrentUser.get('lng')
        )
      )

    afterEach ->
      mapMock.restore()

    describe 'when there is no geolocation support', ->
      it 'sets the map center from the user model', ->
        navigator.geolocation = null
        RollFindr.GlobalEvents.trigger('geolocate', {})

        mapMock.verify() # TODO: Verify arguments

    describe 'when geolocation fails', ->
      it 'sets the map center from the user model', ->
        navigator.geolocation = {
          getCurrentPosition: sinon.stub().callsArg(1)
        }

        RollFindr.GlobalEvents.trigger('geolocate', {})
        mapMock.verify() # TODO: Verify arguments


    describe 'when geolocation succeeds', ->
      it 'sets the map center from the result', ->
        navigator.geolocation = {
          getCurrentPosition: sinon.stub().callsArgWith(0, GEOLOCATE_RESULT)
        }

        RollFindr.GlobalEvents.trigger('geolocate', {})
        mapMock.verify() # TODO: Verify arguments

