#= require spec_helper
#= require backbone/rollfindr

describe 'Views.LocationInstructorsView', ->
  viewModel =
    title: "Northwest Jiu Jitsu Academy"
    website: "nwjja.com"
    id: "541d0d21afd99488ff000014"
    team_id: "541d0d20afd99488ff000013"
    instructors: []

  testInstructorId = "541d0d20afd99488ff000013"

  subject = null

  setupDom = ->
    b = $('body')
    b.html('')
    b.addHtml('div', {'class': 'items' })
    b.addHtml('a', {'class': 'add-instructor'})
    b.addHtml('div', {'class': 'add-instructor-dialog modal'})
    b.addHtml('a', {'data-id': testInstructorId, 'class': 'remove-instructor'})

  setupTestServer = ->
    this.server = sinon.fakeServer.create()

    instructorsResponseBody = [
      {
        belt_rank: "black"
        name: "Roberto Correa"
        id: testInstructorId
        param: testInstructorId
        full_lineage: []
        stripe_rank: 4
        belt_rank: 'black'
        lineal_parent_id: "5476798db3e83f66d6000072"
      }
    ]

    instructorsResponse = [
      200,
      {'Content-Type': 'application/json'},
      JSON.stringify(instructorsResponseBody)
    ]
    this.server.respondWith(
      'GET',
      Routes.location_instructors_path(viewModel.id),
      instructorsResponse
    )

    emptyResponse = [
      200,
      {'Content-Type': 'application/json'},
      '{}'
    ]
    this.server.respondWith(
      'DELETE',
      Routes.location_instructor_path(viewModel.id, testInstructorId),
      emptyResponse
    )

  beforeEach ->
    setupDom()
    setupTestServer()
    model = new RollFindr.Models.Location(viewModel)
    subject = new RollFindr.Views.LocationInstructorsView({model: model, el: $('body')})
    server.respond()

  describe "add instructor", ->
    it 'click .add-instructor shows the instructor modal', ->
      $('.add-instructor').click()
      modalData = $('.add-instructor-dialog').data('bs.modal')
      modalData.isShown.should.equal(true)


  describe "remove instructor", ->
    it 'click .remove-instructor removes the instructor', ->
      subject.model.get('instructors').length.should.equal(1)
      $('.remove-instructor').click()
      subject.model.get('instructors').length.should.equal(0)


