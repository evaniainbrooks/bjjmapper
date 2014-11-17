#= require spec_helper
#= require application

describe 'App#ConfirmDialog', ->
  beforeEach ->
    RollFindr.ConfirmDialog({title: 'test title wow', body: 'such content wow', url: 'testurl'})

  it 'shows a dialog', ->
    $('.confirm-dialog').length.should.equal(1)

  it 'has defaults', ->
    $('.confirm-dialog').should.contain('Confirm')

  it 'explicit options override defaults', ->
    $('.confirm-dialog').should.contain('test title wow')

