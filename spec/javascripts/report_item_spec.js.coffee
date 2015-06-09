#= require spec_helper
#= require report_item

describe '[data-report-item]', ->
  beforeEach ->
    $('body').addHtml('div', { 'class': 'report-dialog' })
    $('body').addHtml('a', { 'data-report-item': true, 'href': '#' })

  it 'click opens the .report-dialog modal', ->
    $('[data-report-item]').click()
    $('.report-dialog').data('bs.modal').isShown.should.equal(true)


