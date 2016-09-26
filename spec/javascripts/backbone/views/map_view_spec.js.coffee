#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/map
#= require backbone/views/map/map_view

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
    describe 'when geolocation fails', ->
      it 'sets the map center from the user model', ->


    describe 'when geolocation succeeds', ->
      it 'sets the map center from the result', ->

