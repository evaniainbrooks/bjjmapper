#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/event
#= require backbone/views/create-event-view

describe 'Views.CreateEventView', ->
  view = null

  setupDom = ->
    f = $('body').addHtml('form', {class: 'create-event-dialog'})
    f.addHtml('input', {type: 'radio', name: 'event[event_type]', value: 1, 'data-event-type-name': 'tournament'})
    f.addHtml('input', {type: 'text', name: 'event[title]'})
    f.addHtml('input', {type: 'text', name: 'event[organization]'})
    f.addHtml('input', {type: 'text', name: 'event[starting]'})
    f.addHtml('input', {type: 'text', name: 'event[ending]'})
    f.addHtml('button', {type: 'Submit'})

  beforeEach ->
    setupDom()
    view = new RollFindr.Views.CreateEventView(el: $('.create-event-dialog'))

  describe 'eventType changed', ->
    it 'adds the eventType class to the form', ->
      $('form').should.not.have.class('tournament')
      $('[name="event[event_type]"]').click()
      $('form').should.have.class('tournament')

  it 'disables the submit button on create', ->
    $('[type=submit]').should.be.disabled

  it 'enables the submit button when title, date and org are entered', ->
    $('[name="event[title]"]').val('title')
    $('[name="event[starting]"]').val(Date.now() / 1000)
    $('[name="event[ending]"]').val(Date.now() / 1000)
    $('[name="event[organization]"]').val('title')
    $('[name="event[organization]"]').trigger('change')

    $('[type=submit]').should.not.be.disabled



