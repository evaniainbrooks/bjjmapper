#= require spec_helper
#= require backbone/rollfindr

describe "Models.Student", ->
  subject = new RollFindr.Models.Student()
  instructor_id = 10
  id = 5

  beforeEach ->
    subject.set('instructor_id', instructor_id)
    subject.set('id', id)

  it 'has a url', ->
    subject.url().should.equal(Routes.user_student_path(instructor_id, id))
