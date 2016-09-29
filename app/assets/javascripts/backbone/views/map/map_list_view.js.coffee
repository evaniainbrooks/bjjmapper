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
    if null != @activeMarkerId
      listElem = $("[data-id='#{@activeMarkerId}']")

      if 'fixed' == $('.map-canvas').css('position')
        $('html, body').animate({
          scrollTop: listElem.offset().top - $('.navbar').height()
        }, 1000)
      @render()

  listItemClicked: (e)->
    id = $(e.currentTarget).data('id')
    type = $(e.currentTarget).data('type')

    $(e.currentTarget).siblings().removeClass('marker-active')
    $(e.currentTarget).addClass('marker-active')
    RollFindr.GlobalEvents.trigger('markerActive', {id: id})

