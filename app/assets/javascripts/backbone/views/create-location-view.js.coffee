class RollFindr.Views.CreateLocationView extends Backbone.View
  el: $('.new-location-dialog'),
  events: {
    'change [name="location[team_id]"]': 'changeTeam'
    'keyup [name="location[title]"]': 'enableSubmit'
  }

  initialize: ->
    _.bindAll(this, 'changeTeam', 'enableSubmit')

  changeTeam: (e)->
    teamImg = $('option:selected', e.currentTarget).data('img-src')
    imgElem = @$('.edit-image')
    imgElem.attr('src', if teamImg.length > 0 then teamImg else imgElem.data('default-src'))

    @enableSubmit()

  isTeamSelected: ->
    @$('option:selected').length > 0

  isNameEntered: ->
    @$('input[name="location[title]"]').val().length > 0

  enableSubmit: ->
    if @isNameEntered() && @isTeamSelected()
      @$('[type="submit"]').removeAttr('disabled')
