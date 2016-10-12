class RollFindr.Views.UpcomingEventsView extends Backbone.View
  el: $('.upcoming-events')
  collection: new RollFindr.Collections.EventsCollection()
  template: JST['templates/upcoming-event']
  initialize: (options)->
    _.bindAll(this, 'render')
    @listenTo(@collection, 'sync reset', @render)
    @collection.fetch()

  render: ->
    @$('.items').empty()
    if @collection.size() > 0
      @$el.removeClass('empty')
      _.each @collection.models, (e)=>
        id = e.get('id')
        element = @template({event: e.toJSON()})
        @$('.items').append(element)
    else
      @$el.addClass('empty')
