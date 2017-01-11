#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/location
#= require backbone/views/schedule-view
#= require backbone/views/events/create-event-view

describe 'Views.ScheduleView', ->
  model = new RollFindr.Models.Location({id: '123'})
  view = null

  beforeEach ->
    view = new RollFindr.Views.ScheduleView({el: $('body'), model: model})

  describe 'fullcalendar', ->
    it 'fetches the events for the location', ->

  describe 'subviews', ->
    it 'has a create event dialog view', ->
      view.createEventView.should.be.instanceof(RollFindr.Views.CreateEventView)

