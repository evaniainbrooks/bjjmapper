#= require backbone/models/location
class TermFilter
  setQuery: (q, center, distance)->
    if (@query != q)
      @query = q

    if @isEmpty()
      @collection.reset()
    else
      @collection.fetch({data: {center: center, distance: distance, query: @query}})

  query: ""
  isEmpty: ->
    !@query? || @query.length <= 0
  collection: new RollFindr.Collections.LocationsCollection()
  filterCollection: (collectionToFilter)->
    if @collection.models.length <= 0
      if @isEmpty()
        return collectionToFilter
      else
        return []

    filters = _.map(@collection.models, (f)->
      [f.get('id'), 1]
    )

    activeFilters = _.object(filters)
    return collectionToFilter.filter((f)->
      teamId = f.get('id')
      activeFilters[teamId]?
    )

window.TermFilter = TermFilter

