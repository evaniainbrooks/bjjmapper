class RollFindr.Views.CreateLocationView extends Backbone.View
  el: $('.new-location-dialog'),
  events: {
    'change [name="location[team_id]"]': 'changeTeam'
  }

  initialize: ->
    _.bindAll(this, 'changeTeam')

  changeTeam: (e)->
    teamImg = $('option:selected', e.currentTarget).data('img-src')
    imgElem = @$('.edit-image')
    imgElem.attr('src', if teamImg.length > 0 then teamImg else imgElem.data('default-src'))


