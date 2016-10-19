class RollFindr.Views.UpcomingEventsView extends Backbone.View
  el: $('.upcoming-events')
  collection: new RollFindr.Collections.EventsCollection()
  template: (event)->
    if (event.get('event_type') == RollFindr.Models.Event.EVENT_TYPE_TOURNAMENT)
      return JST['templates/upcoming-tournament']
    else
      return JST['templates/upcoming-seminar']

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
        t = @template(e)
        element = t({event: e.toJSON()})
        @$('.items').append(element)
    else
      @$el.addClass('empty')
