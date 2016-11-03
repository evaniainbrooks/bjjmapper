class RollFindr.Views.MapListView extends Backbone.View
  el: $('.map-list-view')
  tagName: 'div'
  template: (loc)->
    if loc.get('events')? && loc.get('events').length > 0
      if loc.get('events').first().get('event_type') == RollFindr.Models.Event.EVENT_TYPE_TOURNAMENT
        return JST['templates/map/tournament-list-item']
      else
        return JST['templates/map/seminar-list-item']
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
    return if null == @activeMarkerId

    listElem = $(".map-list-item[data-id='#{@activeMarkerId}']")
    return if null == listElem
    
    scrollTopPosition = listElem.offset().top - $('.navbar').height()
    if 'fixed' == $('.map-canvas').css('position')
      $('html, body').animate({
        scrollTop: scrollTopPosition
      }, 1000)

  listItemClicked: (e)->
    id = $(e.currentTarget).data('id')
    type = $(e.currentTarget).data('type')
    @updateActiveMarker(id)
    RollFindr.GlobalEvents.trigger('markerActive', {id: id})

  updateActiveMarker: (id) ->
    @$('.map-list-item').removeClass('marker-active')
    @$("[data-id='#{@activeMarkerId}']").addClass('marker-active')

