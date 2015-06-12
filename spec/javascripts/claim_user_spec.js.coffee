#= require spec_helper
#= require backbone/rollfindr
#= require claim_user
#= require user_helper
#= require js-routes
#= require toastr

describe 'Claim User', ->
  ajaxSpy = null
  testStudent = 'testStudent123'
  commonData =
    format: 'json'
    _method: 'patch'

  beforeEach ->
    ajaxSpy = sinon.spy($, 'ajax')
    stubCurrentUser()

  afterEach ->
    ajaxSpy.restore()

  describe 'Student', ->
    describe 'click [data-claim-student]', ->
      userData = null
      beforeEach ->
        $('body').addHtml('a', 'data-user-id': testStudent, 'data-claim-student': true)
        userData =
          user:
            lineal_parent_id: currentUserId()

      it 'makes an ajax request to set the users instructor_id', ->
        $('[data-claim-student]').click()
        ajaxSpy.calledWithMatch(
          url: Routes.user_path(testStudent)
          method: 'POST'
          data: _.extend({}, commonData, userData)
        ).should.equal(true)

    describe 'click [data-clear-student]', ->
      userData =
        user:
          lineal_parent_id: null

      beforeEach ->
        $('body').addHtml('a', 'data-user-id': testStudent, 'data-clear-student': true)

      it 'makes an ajax request to clear the users instructor_id', ->
        $('[data-clear-student]').click()
        ajaxSpy.calledWithMatch(
          url: Routes.user_path(testStudent)
          method: 'POST'
          data: _.extend({}, commonData, userData)
        ).should.equal(true)

  describe 'Instructor', ->
    describe 'click [data-claim-instructor]', ->
      userData = null
      beforeEach ->
        $('body').addHtml('a', 'data-user-id': testStudent, 'data-claim-instructor': true)
        userData =
          user:
            lineal_parent_id: testStudent

      it 'makes an ajax request to set the current_user instructor_id', ->
        $('[data-claim-instructor]').click()
        ajaxSpy.calledWithMatch(
          url: Routes.user_path(currentUserId())
          method: 'POST'
          data: _.extend({}, commonData, userData)
        ).should.equal(true)

    describe 'click [data-clear-instructor]', ->
      userData =
        user:
          lineal_parent_id: null

      beforeEach ->
        $('body').addHtml('a', 'data-user-id': testStudent, 'data-clear-instructor': true)

      it 'makes an ajax request to clear the current_user instructor_id', ->
        $('[data-clear-instructor]').click()
        ajaxSpy.calledWithMatch(
          url: Routes.user_path(currentUserId())
          method: 'POST'
          data: _.extend({}, commonData, userData)
        ).should.equal(true)

