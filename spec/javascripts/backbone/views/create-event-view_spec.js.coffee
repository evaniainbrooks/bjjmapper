#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/event
#= require backbone/views/create-event-view

describe 'Views.CreateEventView', ->
  view = null

  setupDom = ->
    $('body')
      .addHtml('form', {class: 'create-event-dialog'})
      .addHtml('input', {type: 'radio', name: 'event[event_type]', value: 1, 'data-event-type-name': 'tournament'})

  beforeEach ->
    setupDom()
    view = new RollFindr.Views.CreateEventView(el: $('.create-event-dialog'))

  describe 'eventType changed', ->
    it 'adds the eventType class to the form', ->
      $('form').should.not.have.class('tournament')
      $('[name="event[event_type]"]').click()
      $('form').should.have.class('tournament')

