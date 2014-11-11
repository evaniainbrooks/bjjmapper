#= require spec_helper
#

describe 'Views.MapViewList', ->
  collection = new RollFindr.Collections.LocationsCollection()
  view = null

  beforeEach ->
    view = new RollFindr.Views.MapViewList({el: $('body'), filteredCount: 99, collection: collection})

  it 'renders itself on initialize', ->

  it 'displays the count and filtered count', ->

  describe 'when there are no locations', ->
    it 'adds the empty class to the container and displays an error message', ->

  describe 'when there are locations', ->
    it 'renders the map list template for each item in the collection', ->

