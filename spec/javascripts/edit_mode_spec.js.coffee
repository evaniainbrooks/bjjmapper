#= require spec_helper
#= require application

describe 'edit mode', ->
  beforeEach ->
    e = $('body').addHtml('div', { 'class': 'editable edit-mode' })
    e.addHtml('a', { 'data-cancel-edit': true })
    e.addHtml('a', { 'data-begin-edit': true })
    e.addHtml('div', { 'class': 'login-modal modal' })

  it '[data-cancel-edit] removes the edit-mode class when clicked', ->
    $('[data-cancel-edit]').click()
    $('.editable').should.not.have.class('edit-mode')

  describe 'when authenticated', ->
    beforeEach ->
      stubCurrentUser()

    it '[data-begin-edit] adds the edit-mode class when clicked', ->
      $('.editable').removeClass('edit-mode')
      $('[data-begin-edit]').trigger('click')
      $('.editable').should.have.class('edit-mode')

  describe 'when not authenticated', ->
    beforeEach ->
      stubAnonymousUser()

    it '[data-begin-edit] shows the login dialog', ->
      $('[data-begin-edit]').trigger('click')
      modalData = $('.login-modal').data('bs.modal')
      modalData.isShown.should.equal(true)
