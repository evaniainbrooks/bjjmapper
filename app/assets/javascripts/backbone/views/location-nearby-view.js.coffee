#= require backbone/views/create-event-view

class RollFindr.Views.LocationNearbyView extends Backbone.View
  el: $('.nearby-locations')
  template: JST['templates/locations/nearby']
  initialize: (options)->
    _.bindAll(this, 'render')

    @template = JST[options.template] if options.template?
    collection_params = {
      lat: @model.get('lat'),
      lng: @model.get('lng'),
      reject: @model.get('param'),
      location_type: [
        RollFindr.Models.Location.LOCATION_TYPE_EVENT_VENUE,
        RollFindr.Models.Location.LOCATION_TYPE_ACADEMY
      ]
    }
    collection_params.count = options.count if options.count?

    @collection = new RollFindr.Collections.NearbyLocationsCollection(collection_params)

    @collection.fetch({
      beforeSend: =>
        @$el.addClass('loading')
      complete: =>
        @$el.removeClass('loading')
    }).done(@render)

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
