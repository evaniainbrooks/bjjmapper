#= require spec_helper
#= require avatar_upload
#= require toastr

describe 'Avatar Upload', ->
  testUrl = '/test/url/1234'
  ajaxSpy = null
  toastrSpy = null

  beforeEach ->
    ajaxSpy = sinon.spy($, 'ajax')
    toastrSpy = sinon.spy(toastr, 'success')

  afterEach ->
    ajaxSpy.restore()
    toastrSpy.restore()

  describe '[data-clear-avatar]', ->
    beforeEach ->
      $('body').addHtml('a', { 'data-clear-avatar': true, 'data-url': testUrl })

    it 'makes ajax request and displays success toast', ->
      $('[data-clear-avatar]').click()
      ajaxSpy.calledWithMatch({type: 'POST', url: testUrl}).should.equal(true)

    afterEach ->
      ajaxSpy.yieldTo('success', {})
      toastrSpy.callCount.should.equal(1)

      ajaxSpy.restore()

  describe '[data-upload-avatar]', ->
    beforeEach ->
      $('body').addHtml('input', { 'type': 'file', 'data-upload-avatar': true, 'data-url': testUrl })

    it 'makes ajax request and displays success toast', ->
      $('[data-upload-avatar]').trigger('change')
      ajaxSpy.calledWithMatch({type: 'POST', url: testUrl}).should.equal(true)

    afterEach ->
      ajaxSpy.yieldTo('success', {})
      toastrSpy.callCount.should.equal(1)

