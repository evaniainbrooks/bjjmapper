#= require spec_helper
#= require backbone/rollfindr

describe "Models.User", ->
  subject = new RollFindr.Models.User()

  it 'has many lineal_children', ->
    subject.get('lineal_children').should.be.an.instanceof(RollFindr.Collections.StudentsCollection)

  it 'has many reviews', ->
    subject.get('reviews').should.be.an.instanceof(RollFindr.Collections.ReviewsCollection)

  it 'has a default anonymous role', ->
    subject.get('role').should.equal('anonymous')
    subject.isAnonymous().should.equal(true)

