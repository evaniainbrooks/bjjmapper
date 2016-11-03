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
    locationData = null
    beforeEach ->
      $('body').addHtml('a', 'data-id': 123, 'data-close-location': true)
      locationData = {closed: true}
    it 'makes an ajax request to close the location', ->
      $('[data-close-location]').click()
      ajaxSpy.calledWithMatch(
        url: Routes.close_location_path(123)
        method: 'POST'
        data: _.extend({}, commonData, locationData)
      ).should.equal(true)
