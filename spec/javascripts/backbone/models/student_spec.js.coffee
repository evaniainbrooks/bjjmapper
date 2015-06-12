#= require spec_helper
#= require backbone/rollfindr
#= require js-routes

describe "Models.Student", ->
  subject = null
  instructor_id = 10
  id = 5

  beforeEach ->
    subject = new RollFindr.Models.Student(id: id, instructor_id: instructor_id)

  it 'has a url', ->
    subject.url().should.equal(Routes.user_student_path(instructor_id, id))
