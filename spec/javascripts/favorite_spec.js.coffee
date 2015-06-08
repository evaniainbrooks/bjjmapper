#= require spec_helper
#= require backbone/rollfindr
#= require favorite

describe 'Favorite button', ->
  ajaxSpy = null
  id = 5000

  beforeEach ->
    e = $('body').addHtml('div', { class: 'favorite' })
    e.addHtml('a', { href: '#', class: 'save-favorite', 'data-id': id })
    e.addHtml('a', { href: '#', class: 'clear-favorite', 'data-id': id })

    ajaxSpy = sinon.spy($, 'ajax')

  afterEach ->
    ajaxSpy.restore()

  describe '.save-favorite', ->
    it 'makes an ajax request to save the favorite', ->
      $('.save-favorite').click()
      ajaxSpy.callCount.should.equal(1)
      ajaxSpy.firstCall.args[0]['data'].should.have.property('delete', 0)

    it 'toggles the .saved class', ->
      $('.favorite').should.not.have.class('saved')
      $('.save-favorite').click()
      $('.favorite').should.have.class('saved')

  describe '.clear-favorite', ->
    it 'makes an ajax request to remove the favorite', ->
      $('.clear-favorite').click()
      ajaxSpy.callCount.should.equal(1)
      ajaxSpy.firstCall.args[0]['data'].should.have.property('delete', 1)

    it 'toggles the .saved class', ->
      $('.favorite').addClass('saved')
      $('.clear-favorite').click()
      $('.favorite').should.not.have.class('saved')
