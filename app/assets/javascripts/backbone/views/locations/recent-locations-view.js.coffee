class RollFindr.Views.RecentLocationsView extends Backbone.View
  el: $('.recent-locations')
  tagName: 'div'
  template: JST['templates/locations/recent-list-item']
  collection: null
  initialize: (options)->
    _.bindAll(this, 'render')
    
    count = options.count || 5
    @collection = new RollFindr.Collections.RecentLocationsCollection({count: count})
    @collection.fetch({
      beforeSend: =>
        @$el.addClass('loading')
      complete: =>
        @$el.removeClass('loading')
    }).done(@render)

  render: ->
    @$('.items').empty()
    if @collection.size() > 0
      @$('.items').removeClass('empty')
      _.each @collection.models, (loc)=>
        locElement = @template({location: loc.toJSON(), active: false})
        @$('.items').append(locElement)
    else
      @$('.items').addClass('empty')
