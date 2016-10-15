#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/location
#= require backbone/views/location-show-view

describe 'Views.LocationShowView', ->
  viewModel = {"city":"Seattle","country":"US","created_at":"created 13 days ago","description":"","directions":"","email":"","image":"/assets/academy-default-100.jpg","modifier_id":null,"phone":"2064408856","postal_code":"98103","state":"WA","street":"942 N 95th St","title":"Northwest Jiu Jitsu Academy","updated_at":"updated 7 days ago","user_id":null,"version":2,"website":"nwjja.com","id":"541d0d21afd99488ff000014","team_id":"541d0d20afd99488ff000013","instructors":["5418a841afd994513400001f","541b9672afd99446c9000031"],"coordinates":[47.69796890000001,-122.3453317],"team_name":"Team Machado","address":"942 N 95th St, Seattle, WA, US, 98103"}
  view = null
  testInstructorId = viewModel.instructors[0]
  beforeEach ->
    b = $('body')
    b.addHtml('a', {'class': 'add-instructor-menu'})
    b.addHtml('div', {'class': 'add-instructor-dialog modal'})
    b.addHtml('a', {'data-id': testInstructorId, 'class': 'remove-instructor'})
    b.addHtml('a', {'class': 'add-review'})
    b.addHtml('a', {'class': 'add-review-dialog modal'})
    view = new RollFindr.Views.LocationShowView({
      model: viewModel,
      mapModel: {},
      el: b,
    })

  describe "add instructor menu", ->
    it 'click .add-instructor-menu shows the instructor modal', ->
      $('.add-instructor-menu').click()
      modalData = $('.add-instructor-dialog').data('bs.modal')
      modalData.isShown.should.equal(true)

  describe "add review", ->
    it 'click .add-review shows the review modal', ->
      $('.add-review').click()
      modalData = $('.add-review-dialog').data('bs.modal')
      modalData.isShown.should.equal(true)

  describe "subviews", ->
    it 'has a calendar subview', ->
      view.scheduleView.should.be.instanceof(RollFindr.Views.ScheduleView)
    it 'has a map subview', ->
      view.mapView.should.be.instanceof(RollFindr.Views.StaticMapView)

    it 'has a nearby locations subview', ->
      view.nearbyView.should.be.instanceof(RollFindr.Views.LocationNearbyView)

    it 'has an instructors subview', ->
      view.instructorsView.should.be.instanceof(RollFindr.Views.LocationInstructorsView)

    it 'has a reviews subview', ->
      view.reviewsView.should.be.instanceof(RollFindr.Views.ReviewsView)
