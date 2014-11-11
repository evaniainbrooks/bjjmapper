class RollFindr.Views.MapViewList extends Backbone.View
  el: $('.location-list')
  tagName: 'div'
  template: JST['templates/locations/map-list-item']
  filteredCount: 0
  collection: null
  initialize: ->
    @render()

  render: ->
    @$el.addClass('empty') unless @collection.length > 0
    @$('.list-count').text("Displaying #{@collection.length} locations (#{@filteredCount} filtered)")
    @$('.items').html('')
    _.each @collection, (loc)=>
      locElement = @template({filteredCount: @filteredCount, location: loc.toJSON()})
      @$('.items').append(locElement)
