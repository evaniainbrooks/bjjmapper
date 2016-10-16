class RollFindr.Views.NavbarView extends Backbone.View
  el: $('.navbar')
  tagName: 'div'
  events: {
    'click [data-geolocate]': 'geolocateMap'
    'click [data-show-list]': 'scrollToList'
    'click [data-show-map]': 'scrollToMap'
    'submit form[role="search"]': 'search'
  }
  initialize: ->
    _.bindAll(this, 'geolocateMap', 'search', 'scrollToList', 'scrollToMap')
  geolocateMap: ->
    @$('[name="geoquery"]').val('')
    RollFindr.GlobalEvents.trigger('geolocate')
  search: (e)->
    searchQuery = @$('[name="query"]').val()
    searchLocation = @$('[name="geoquery"]').val()

    window.location = Routes.map_path({query: searchQuery, geoquery: searchLocation}) if (window.location.pathname != '/map')

    RollFindr.GlobalEvents.trigger('search', {
      query: searchQuery
      geoquery: searchLocation
    })

    #@$('[name="location"]').val('')
    e.preventDefault()

  scrollToList: ->
    $('html, body').animate({
      scrollTop: $('.map-list-view').offset().top - @$el.height()
    }, 1000)
  scrollToMap: ->
    $('html, body').animate({
      scrollTop: 0
    }, 1000)
