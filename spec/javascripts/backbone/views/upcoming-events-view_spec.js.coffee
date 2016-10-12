#= require spec_helper
#= require backbone/rollfindr

describe 'Views.UpcomingEventsView', ->
  renderSpy = null
  view = null
  collection = new RollFindr.Collections.EventsCollection()
  setupDom = ->
    $('body').addHtml('div', {class: 'upcoming-events'}).addHtml('div', {class: 'items'})

  setupSpies = ->
    renderSpy = sinon.spy(RollFindr.Views.UpcomingEventsView.prototype, 'render')

  beforeEach ->
    this.server = sinon.fakeServer.create()
    emptyResponse = [204, {'Content-Type': 'application/json'}, '{}']
    this.server.respondWith('GET','/events/upcoming',emptyResponse)

    setupSpies()
    setupDom()
    view = new RollFindr.Views.UpcomingEventsView({collection: collection, el: $('.upcoming-events')})

  afterEach ->
    this.server.restore()
    RollFindr.Views.UpcomingEventsView.prototype.render.restore()

  it 'renders itself when the collection is updated', ->
    collection.trigger('sync')
    sinon.assert.called(renderSpy)

  it 'adds the empty class when no items are returned', ->
    collection.trigger('sync')
    $('.upcoming-events').should.have.class('empty')

