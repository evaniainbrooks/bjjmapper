#= require backbone/views/create-event-view

class RollFindr.Views.LocationNearbyView extends Backbone.View
  el: $('.nearby-locations')
  template: JST['templates/locations/nearby']
  initialize: ->
    _.bindAll(this, 'render')

    @collection = new RollFindr.Collections.NearbyLocationsCollection({
      location: @model.get('id')
    })

    @collection.fetch().done(@render)

  render: ->
    @$('.items').empty()
    if @collection.size() > 0
      _.each @collection.models, (loc)=>
        id = loc.get('id')
        locElement = @template({location: loc.toJSON(), active: @activeMarkerId == id})
        @$('.items').append(locElement)
    else
      @$el.addClass('empty')
      (adsbygoogle = window.adsbygoogle || []).push({})
