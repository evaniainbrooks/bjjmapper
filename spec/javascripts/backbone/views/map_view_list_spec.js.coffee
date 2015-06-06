#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/location
#= require backbone/views/map/locations_list_view

describe 'Views.MapViewList', ->
  collection = new RollFindr.Collections.LocationsCollection()
  view = null

  beforeEach ->
    view = new RollFindr.Views.MapLocationsListView({el: $('body'), filteredCount: 99, collection: collection})

  it 'listens on the global markerActive event', ->

  it 'displays the visible count and filtered count', ->

  describe 'when there are no locations', ->
    it 'adds the empty class to the container', ->

  describe 'when there are locations', ->
    it 'removes the empty class', ->

    it 'renders the map list template for each item in the collection', ->

  describe 'click .location-list-item', ->
    it 'adds the active class', ->

    it 'triggers the global markerActive event', ->


