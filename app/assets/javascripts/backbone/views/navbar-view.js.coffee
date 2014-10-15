class RollFindr.Views.NavbarView extends Backbone.View
  el: $('.navbar')
  tagName: 'div'
  events: {
    'click [data-geolocate]': 'geolocateMap'
    'submit form[role="search"]': 'search'
  }
  initialize: ->
    _.bindAll(this, 'geolocateMap', 'search')
  geolocateMap: ->
    @$('[name="location"]').val('')
    RollFindr.GlobalEvents.trigger('geolocate')
  search: (e)->
    searchQuery = @$('[name="query"]').val()
    searchLocation = @$('[name="location"]').val()
    RollFindr.GlobalEvents.trigger('search', {
      query: searchQuery
      location: searchLocation
    })
    e.preventDefault()

