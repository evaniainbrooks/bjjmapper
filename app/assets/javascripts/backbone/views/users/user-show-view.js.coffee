class RollFindr.Views.UserShowView extends Backbone.View
  el: $('.show-user')
  tagName: 'div'
  initialize: ->
    @studentsView = new RollFindr.Views.UserStudentsView({ model: @model })
    @reviewsView = new RollFindr.Views.UserReviewsView({ model: @model })
    @scheduleView = new RollFindr.Views.ScheduleView({ model: @model, el: @$('.scheduler-container'), editable: false })
