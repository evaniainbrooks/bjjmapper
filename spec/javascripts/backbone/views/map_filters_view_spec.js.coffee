#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/map
#= require backbone/views/map/filters_view

describe 'Views.FiltersView', ->
  LOCATION_FILTER = 1
  EVENT_FILTER = 4

  view = null

  setupDom = ->
    filterList = $('body').empty().addHtml('div', {'class': 'filter-list'})
    filterList.addHtml('input', {'type': 'checkbox', 'data-type': 'event', 'data-id': EVENT_FILTER})
    filterList.addHtml('input', {'type': 'checkbox', 'data-type': 'location', 'data-id': LOCATION_FILTER})

  beforeEach ->
    setupDom()

  describe 'initialize', ->
    beforeEach ->
      setupDom()

    it 'does not enable filters when no filters are passed', ->
      view = new RollFindr.Views.FiltersView({locationFilter: [], eventFilter: [], el: $('body')})

      $('[type="checkbox"]:checked').length.should.eq(0)

    it 'enables filters when filters are passed', ->
      view = new RollFindr.Views.FiltersView({locationFilter: [LOCATION_FILTER], eventFilter: [EVENT_FILTER], el: $('body')})

      $('[type="checkbox"]:checked').length.should.eq(2)

