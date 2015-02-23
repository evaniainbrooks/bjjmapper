class RollFindr.Views.RecentLocationsView extends Backbone.View
  el: $('.recent-locations')
  tagName: 'div'
  template: JST['templates/locations/recent-list-item']
  collection: null
  initialize: (options)->
    _.bindAll(this, 'render')

    @collection = new RollFindr.Collections.RecentLocationsCollection({count: 5})
    @collection.fetch().done(@render)

  render: ->
    @$el.empty()
    _.each @collection.models, (loc)=>
      locElement = @template({location: loc.toJSON(), active: false})
      @$el.append(locElement)
