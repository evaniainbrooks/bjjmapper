#= require spec_helper
#= require backbone/rollfindr

describe "Models.User", ->
  userId = "evan123"
  subject = new RollFindr.Models.User({id: userId})

  it 'has many lineal_children', ->
    subject.get('lineal_children').should.be.an.instanceof(RollFindr.Collections.StudentsCollection)
    subject.get('lineal_children').user_id.should.equal(userId)

  it 'has many reviews', ->
    subject.get('reviews').should.be.an.instanceof(RollFindr.Collections.ReviewsCollection)
    subject.get('reviews').user_id.should.equal(userId)

  it 'has many events', ->
    subject.get('events').should.be.an.instanceof(RollFindr.Collections.UserEventsCollection)
    subject.get('events').user_id.should.equal(userId)

  it 'has a default anonymous role', ->
    subject.get('is_anonymous').should.equal(true)
    subject.isAnonymous().should.equal(true)

