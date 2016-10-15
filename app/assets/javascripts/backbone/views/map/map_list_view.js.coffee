class RollFindr.Views.MapListView extends Backbone.View
  el: $('.map-list-view')
  tagName: 'div'
  template: (loc)->
    if loc.get('events')? && loc.get('events').length > 0
      return JST['templates/map/event-list-item']
    else
      return JST['templates/map/academy-list-item']

  activeMarkerId: null
  model: null
  events: {
    'click .map-list-item': 'listItemClicked'
  }
  initialize: (options)->
    _.bindAll(this, 'listItemClicked', 'activeMarkerChanged', 'render')
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)
    @markerIdFunction = options.markerIdFunction

  render: (filteredCount)->
    @$('.location-list').removeClass('loading')
    if @model.get('locations').length == 0
      @$('.location-list').addClass('empty')
    else
      @$('.location-list').removeClass('empty')

    if (undefined != filteredCount)
      @$('.list-count').text("Displaying #{@model.get('locations').length} locations (#{filteredCount} filtered)")

    @$('.items').empty()
    _.each @model.get('locations').models, (loc)=>
      template = @template(loc)
      id = loc.get('id')
      color = loc.getColor()
      loc.set('marker_id', @markerIdFunction(id))
      locElement = $(template({location: loc.toJSON(), active: @activeMarkerId == id})).addClass(color)

      @$('.items').append(locElement)

  activeMarkerChanged: (e)->
    @activeMarkerId = e.id
    @updateActiveMarker(e.id)
    if null != @activeMarkerId
      listElem = $("[data-id='#{@activeMarkerId}']")

      if 'fixed' == $('.map-canvas').css('position')
        $('html, body').animate({
          scrollTop: listElem.offset().top - $('.navbar').height()
        }, 1000)

  listItemClicked: (e)->
    id = $(e.currentTarget).data('id')
    type = $(e.currentTarget).data('type')
    @updateActiveMarker(id)
    RollFindr.GlobalEvents.trigger('markerActive', {id: id})

  updateActiveMarker: (id) ->
    @$('.map-list-item').removeClass('marker-active')
    @$("[data-id='#{@activeMarkerId}']").addClass('marker-active')

