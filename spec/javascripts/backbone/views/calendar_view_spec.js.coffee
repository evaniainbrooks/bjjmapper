#= require spec_helper
#

describe 'Views.CalendarView', ->
  model = new RollFindr.Models.Location({id: '123'})
  view = null

  beforeEach ->
    view = new RollFindr.Views.CalendarView({el: $('body'), model: model})

  describe 'fullcalendar', ->
    it 'fetches the events for the location', ->

  describe 'subviews', ->
    it 'has a create event dialog view', ->
      view.createEventView.should.be.instanceof(RollFindr.Views.CreateEventView)

