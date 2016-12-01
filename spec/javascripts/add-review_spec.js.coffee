#= require spec_helper
#= require backbone/rollfindr

describe 'Add Review Modal', ->
  view = null
  beforeEach ->
    b = $('body')
    b.addHtml('a', {'data-location-id': 1234, 'class': 'add-review'})
    b.addHtml('a', {'class': 'add-review-dialog modal'})
 
    view = new RollFindr.Views.AddReviewView(el: $('body'))

  describe "add review", ->
    xit 'click .add-review shows the review modal', ->
      $('.add-review').click()
      modalData = $('.add-review-dialog').data('bs.modal')
      modalData.isShown.should.equal(true)
