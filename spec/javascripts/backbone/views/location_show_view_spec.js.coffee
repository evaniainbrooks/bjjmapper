#= require spec_helper
#= require application

describe 'Views.LocationShowView', ->
  viewModel = {"city":"Seattle","country":"US","created_at":"created 13 days ago","description":"","directions":"","email":"","image":"/assets/academy-default-100.jpg","modifier_id":null,"phone":"2064408856","postal_code":"98103","state":"WA","street":"942 N 95th St","title":"Northwest Jiu Jitsu Academy","updated_at":"updated 7 days ago","user_id":null,"version":2,"website":"nwjja.com","id":"541d0d21afd99488ff000014","team_id":"541d0d20afd99488ff000013","instructors":["5418a841afd994513400001f","541b9672afd99446c9000031"],"coordinates":[47.69796890000001,-122.3453317],"team_name":"Team Machado","address":"942 N 95th St, Seattle, WA, US, 98103"}
  view = null
  testInstructorId = viewModel.instructors[0]
  beforeEach ->
    $('body').addHtml('a', {'class': 'add-instructor'})
    $('body').addHtml('div', {'class': 'add-instructor-dialog modal'})
    $('body').addHtml('a', {'data-id': testInstructorId, 'class': 'remove-instructor'})
    view = new RollFindr.Views.LocationShowView({
      model: viewModel,
      mapModel: {},
      el: $('body'),
    })

  describe "add instructor", ->
    it 'click .add-instructor shows the instructor modal', ->
      $('.add-instructor').click()
      modalData = $('.add-instructor-dialog').data('bs.modal')
      modalData.isShown.should.equal(true)

  describe "remove instructor", ->
    it 'click .remove-instructor removes the instructor', ->
      view.model.get('instructors').length.should.equal(2)
      $('.remove-instructor').click()
      view.model.get('instructors').length.should.equal(1)


  describe "subviews", ->
    it 'has a calendar subview', ->
      view.calendarView.should.be.instanceof(RollFindr.Views.CalendarView)
    it 'has a map subview', ->
      view.mapView.should.be.instanceof(RollFindr.Views.MapView)
