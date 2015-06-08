#= require spec_helper
#= require backbone/rollfindr

describe "Models.Instructor", ->
  subject = new RollFindr.Models.Instructor()
  location_id = 10
  id = 5

  beforeEach ->
    subject.set('location_id', location_id)
    subject.set('id', id)

  it 'has a url', ->
    subject.url().should.equal(Routes.location_instructor_path(location_id, id))
