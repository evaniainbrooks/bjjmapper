#= require spec_helper
#= require backbone/rollfindr

describe "Models.ReviewsResponse", ->
  locationId = "12345"
  subject = new RollFindr.Models.ReviewsResponse({location_id: locationId})

  it 'has many reviews', ->
    subject.get('reviews').should.be.an.instanceof(RollFindr.Collections.ReviewsCollection)
    subject.get('reviews').location_id.should.equal(locationId)
