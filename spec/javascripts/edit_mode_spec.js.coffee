#= require spec_helper

describe 'edit mode', ->
  beforeEach ->
    e = $('body').addHtml('div', { 'class': 'editable edit-mode' })
    e.addHtml('a', { 'data-cancel-edit': true })
    e.addHtml('a', { 'data-begin-edit': true })

  it '[data-cancel-edit] removes the edit-mode class when clicked', ->
    $('[data-cancel-edit]').click()
    $('.editable').should.not.have.class('edit-mode')

  it '[data-begin-edit] adds the edit-mode class when clicked', ->
    $('[data-cancel-edit]').click()
    $('.editable').should.not.have.class('edit-mode')
    $('[data-begin-edit]').trigger('click')
    $('.editable').should.have.class('edit-mode')


