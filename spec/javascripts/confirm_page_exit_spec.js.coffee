#= require spec_helper
#= require backbone/rollfindr
#= require confirm_page_exit

describe 'Confim Page Exit', ->
  it 'enableConfirmPageExit installs the onbeforeunload handler', ->
    should.not.exist(window.onbeforeunload)
    window.enableConfirmPageExit()
    window.onbeforeunload.should.not.equal(null)

  it 'onbeforeunload handler returns a string', ->
    window.enableConfirmPageExit()
    window.onbeforeunload().should.be.a('string')

  it 'disableConfirmPageExit clears the onbeforeunload handler', ->
    window.enableConfirmPageExit()
    window.onbeforeunload.should.not.equal(null)
    window.disableConfirmPageExit()
    should.not.exist(window.onbeforeunload)

  describe 'submit click handler', ->
    disableHandlerCallback = null
    beforeEach ->
      disableHandlerCallback = sinon.spy(window, 'disableConfirmPageExit')
      $('body').addHtml('button', { 'type': 'submit' })

    it 'calls the disableConfirmPageExit function', ->
      $('button[type="submit"]').click()
      disableHandlerCallback.callCount.should.equal(1)

