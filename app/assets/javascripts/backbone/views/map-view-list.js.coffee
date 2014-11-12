class RollFindr.Views.MapViewList extends Backbone.View
  el: $('.location-list')
  tagName: 'div'
  template: JST['templates/locations/map-list-item']
  activeMarkerId: null
  collection: null
  events: {
    'click .location-list-item': 'listItemClicked'
  }
  initialize: ->
    _.bindAll(this, 'listItemClicked', 'activeMarkerChanged', 'render')
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)

  render: (filteredCount)->
    if @collection.length == 0
      @$el.addClass('empty')
    else
      @$el.removeClass('empty')

    @$('.list-count').text("Displaying #{@collection.length} locations (#{filteredCount} filtered)")
    @$('.items').empty()
    _.each @collection.models, (loc)=>
      id = loc.get('id')
      locElement = @template({location: loc.toJSON(), active: @activeMarkerId == id})
      @$('.items').append(locElement)

  activeMarkerChanged: (e)->
    @activeMarkerId = e.id

  listItemClicked: (e)->
    id = $(e.currentTarget).data('id')
    $(e.currentTarget).siblings().removeClass('marker-active')
    $(e.currentTarget).addClass('marker-active')
    RollFindr.GlobalEvents.trigger('markerActive', {id: id})

