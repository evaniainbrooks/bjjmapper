#= require spec_helper
#= require backbone/rollfindr
#= require confirm_dialog
#= require toastr

describe 'App#ConfirmDialog', ->
  beforeEach ->
    $(document).ready (done)->
      RollFindr.ConfirmDialog({title: 'test title wow', body: 'such content wow', url: 'testurl', returnto: 'someotherurl'})

  it 'shows a dialog', (done)->
    setTimeout ->
      $('.confirm-dialog').length.should.equal(1)
      done()
    , 500

  it 'has defaults', (done)->
    setTimeout ->
      $('.confirm-dialog').html().should.match(/Confirm/)
      done()
    , 500

  it 'explicit options override defaults', (done)->
    setTimeout ->
      $('.confirm-dialog').html().should.match(/test title wow/)
      done()
    , 500

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

    it 'displays an error message on failure', ->
      toastrSpy = sinon.spy(toastr, 'error')

      $('body').delegate '.confirm-dialog button.confirm', 'click', (e)=>
        ajaxSpy.getCall(0).args[0].error()
        toastrSpy.callCount.should.equal(1)

      $('button[type="submit"]').click()

