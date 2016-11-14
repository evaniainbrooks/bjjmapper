#= require spec_helper
#= require claim-location
#= require js-routes

describe 'Close Location', ->
  ajaxSpy = null
  commonData = 
    format: 'json'

  beforeEach ->
    ajaxSpy = sinon.spy($, 'ajax')

  afterEach ->
    ajaxSpy.restore()

  describe 'click [data-close-location]', ->
    beforeEach ->
      b = $('body')
      b.addHtml('a', 'data-id': 123, 'data-close-location': true)
    it 'makes an ajax request to close the location', ->
      $('[data-close-location]').click()
      ajaxSpy.calledWithMatch(
        url: Routes.close_location_path(123)
        method: 'POST'
        data: _.extend({}, commonData, {reopen: 0}) 
      ).should.equal(true)
  
  describe 'click [data-reopen-location]', ->
    locationData = null
    beforeEach ->
      $('body').addHtml('a', 'data-id': 123, 'data-reopen-location': true)
    it 'makes an ajax request to close the location', ->
      $('[data-reopen-location]').click()
      ajaxSpy.calledWithMatch(
        url: Routes.close_location_path(123)
        method: 'POST'
        data: _.extend({}, commonData, {reopen: 1})
      ).should.equal(true)
