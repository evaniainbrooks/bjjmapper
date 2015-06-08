#= require spec_helper
#= require backbone/rollfindr
#= require confirm_dialog

describe 'App#ConfirmDialog', ->
  beforeEach ->
    RollFindr.ConfirmDialog({title: 'test title wow', body: 'such content wow', url: 'testurl', returnto: 'someotherurl'})

  it 'shows a dialog', ->
    $('.confirm-dialog').length.should.equal(1)

  it 'has defaults', ->
    $('.confirm-dialog').html().should.match(/Confirm/)

  it 'explicit options override defaults', ->
    $('.confirm-dialog').html().should.match(/test title wow/)

  describe 'submit button clicked', ->
    ajaxSpy = null
    beforeEach ->
      ajaxSpy = sinon.spy($, 'ajax')

    afterEach ->
      ajaxSpy.restore()

    it 'submits an ajax POST request', ->
      $('body').delegate '.confirm-dialog button.confirm', 'click', (e)->
        ajaxSpy.callCount.should.equal(1)
        ajaxSpy.getCall(0).args[0].should.have.property('url', 'testurl')

      $('button[type="submit"]').click()

    it 'redirects to the returnto location on success', ->
      $('.confirm-dialog button.confirm').click()
      window.location.should.equal('someotherurl')

