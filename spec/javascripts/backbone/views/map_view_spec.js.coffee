#= require spec_helper
#

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

  it 'has a template', ->
    view.template.should.be.an('function')

  it 'listens to global search event', ->
    RollFindr.GlobalEvents.trigger('search')
    sinon.assert.called(searchSpy)

  it 'listens to global geolocate event', ->
    RollFindr.GlobalEvents.trigger('geolocate')
    sinon.assert.called(geolocateSpy)

  it 'renders itself when the location list is updated', ->
    viewModel.get('locations').trigger('sync')
    sinon.assert.called(renderSpy)
