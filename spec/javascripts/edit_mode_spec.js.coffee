#= require spec_helper
#= require backbone/rollfindr
#= require edit-mode

describe 'Edit Mode', ->
  beforeEach ->
    e = $('body').addHtml('div', { 'class': 'editable edit-mode' })
    e.addHtml('a', { 'data-cancel-edit': true })
    e.addHtml('a', { 'href': '#anchor', 'data-begin-edit': true })
    e.addHtml('div', { 'class': 'login-modal modal' })

  it '[data-cancel-edit] removes the edit-mode class when clicked', ->
    $('[data-cancel-edit]').click()
    $('.editable').should.not.have.class('edit-mode')

  describe 'when authenticated', ->
    beforeEach ->
      stubCurrentUser()

    describe '[data-begin-edit]', ->
      it 'adds the edit-mode class when clicked', ->
        $('.editable').removeClass('edit-mode')
        $('[data-begin-edit]').trigger('click')
        $('.editable').should.have.class('edit-mode')

      it 'prevents the default link action', ->
        @timeout(1000)
        $('[data-begin-edit]').data('follow-href', false)
        $('html').delegate '.editable [data-begin-edit]', 'click', (e)->
          e.isDefaultPrevented().should.equal(true)

        $('[data-begin-edit]').trigger('click')

  describe 'when not authenticated', ->
    beforeEach ->
      stubAnonymousUser()

    describe '[data-begin-edit]', ->
      it 'shows the login dialog', ->
        $('[data-begin-edit]').trigger('click')
        modalData = $('.login-modal').data('bs.modal')
        modalData.isShown.should.equal(true)
