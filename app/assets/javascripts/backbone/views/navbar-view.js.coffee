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
    RollFindr.GlobalEvents.trigger('geolocate')
  search: (e)->
    searchQuery = this.$('[name="query"]').val()
    searchLocation = this.$('[name="location"]').val()
    RollFindr.GlobalEvents.trigger('search', {
      query: searchQuery
      location: searchLocation
    })
    e.preventDefault()


