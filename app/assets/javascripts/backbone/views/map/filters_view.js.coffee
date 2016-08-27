class RollFindr.Views.FiltersView extends Backbone.View
  el: $('.filter-list')
  tagName: 'div'
  locationFilter: 0
  eventFilter: 0
  sortOrder: 0
  events: {
    'click [type="checkbox"]': 'checkBoxClicked'
  }
  initialize: (options)->
    _.bindAll(this,
      'initializeCheckBoxes',
      'render',
      'checkBoxClicked')

    @locationFilter = options.locationFilter
    @eventFilter = options.eventFilter
    @sortOrder = options.sortOrder

    @initializeCheckBoxes()

  initializeCheckBoxes: ->
    _.each @locationFilter, (filterVal)->
      @$("[data-type='location'][data-id='#{filterVal}']").prop('checked', true)
    _.each @eventFilter, (filterVal)->
      @$("[data-type='event'][data-id='#{filterVal}']").prop('checked', true)

  checkBoxClicked: (e)->
    @eventFilter = _.collect @$("[data-type='event']:checked"), (o)->
      $(o).data('id')
    @locationFilter = _.collect @$("[data-type='location']:checked"), (o)->
      $(o).data('id')

