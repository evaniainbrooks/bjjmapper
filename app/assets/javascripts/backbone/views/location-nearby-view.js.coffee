#= require backbone/views/create-event-view

class RollFindr.Views.LocationNearbyView extends Backbone.View
  el: $('.nearby-locations')
  template: JST['templates/locations/nearby']
  initialize: (options)->
    _.bindAll(this, 'render')

    @template = JST[options.template] if options.template?
    @count = options.count
    @collection = new RollFindr.Collections.NearbyLocationsCollection({
      count: @count,
      lat: @model.get('coordinates')[0],
      lng: @model.get('coordinates')[1],
      reject: @model.get('id'),
      location_type: [
        RollFindr.Models.Location.LOCATION_TYPE_EVENT_VENUE,
        RollFindr.Models.Location.LOCATION_TYPE_ACADEMY
      ]
    })

    @collection.fetch().done(@render)

  render: ->
    @$('.items').empty()
    if @collection.size() > 0
      @$el.removeClass('empty')
      _.each @collection.models, (loc)=>
        id = loc.get('id')
        locElement = @template({location: loc.toJSON(), active: @activeMarkerId == id})
        @$('.items').append(locElement)
    else
      @$el.addClass('empty')
      (adsbygoogle = window.adsbygoogle || []).push({})
