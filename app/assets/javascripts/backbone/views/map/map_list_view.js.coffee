class RollFindr.Views.MapListView extends Backbone.View
  el: $('.location-list')
  tagName: 'div'
  academyTemplate: JST['templates/map/academy-list-item']
  eventTemplate: JST['templates/map/event-list-item']
  activeMarkerId: null
  model: null
  events: {
    'click .map-list-item': 'listItemClicked'
  }
  initialize: ->
    _.bindAll(this, 'listItemClicked', 'activeMarkerChanged', 'render')
    RollFindr.GlobalEvents.on('markerActive', @activeMarkerChanged)

  render: (filteredCount)->
    if @model.get('locations').length == 0
      @$el.addClass('empty')
    else
      @$el.removeClass('empty')

    if (undefined != filteredCount)
      @$('.list-count').text("Displaying #{@model.get('locations').length} locations (#{filteredCount} filtered)")

    @$('.items').empty()
    _.each @model.get('locations').models, (loc)=>
      templateType = if loc.get('events')? && loc.get('events').length > 0 then @eventTemplate else @academyTemplate
      id = loc.get('id')
      locElement = templateType({location: loc.toJSON(), active: @activeMarkerId == id})
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

