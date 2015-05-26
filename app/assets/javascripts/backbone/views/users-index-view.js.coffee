class RollFindr.Views.UsersIndexView extends Backbone.View
  model: null
  el: $('.show-users')
  events: {
    'click .create-user': 'createUser'
  }
  initialize: ->
    _.bindAll(this, 'render', 'createUser')

  createUser: ->
    $('.add-instructor-dialog').modal('show')
