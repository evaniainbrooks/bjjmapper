class RollFindr.Views.UpcomingEventsView extends Backbone.View
  el: $('.upcoming-events')
  collection: new RollFindr.Collections.EventsCollection()
  template: JST['templates/upcoming-event']
  initialize: (options)->
    _.bindAll(this, 'render')
    @listenTo(@collection, 'sync reset', @render)
    data = {
      organization_id: options.organization_id,
      instructor_id: options.instructor_id,
      count: options.count
    } if options?

    @collection.fetch({
      data: data,
      beforeSend: =>
        @$el.addClass('loading')
      complete: =>
        @$el.removeClass('loading')
    })
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
