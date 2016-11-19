class RollFindr.Views.FiltersView extends Backbone.View
  el: $('.filter-list')
  tagName: 'div'
  sort_order: []
  events: {
    'click .flag': 'flagClicked'
    'click .display-opt': 'displayTypeCheckBoxClicked'
    'click a.search': 'search'
    'change [name="sort_order"]': 'sortOrderChanged'
    'keyup [name="search"]': 'debounceSearch'
  }
  initialize: (options)->
    @debounceSearch = _.debounce(@search, 800)
    @flagClicked = _.debounce(@flagClicked, 500)

    _.bindAll(this,
      'initializeDisplayTypeCheckBoxes',
      'render',
      'search',
      'debounceSearch',
      'flagClicked',
      'sortOrderChanged',
      'displayTypeCheckBoxClicked')

    @initializeDisplayTypeCheckBoxes()
    @initializePickers()

  flagClicked: (e)->
    flags = {
      closed: 0
      unverified: 0
      bbonly: 0
    }
  
    _.each ['closed', 'unverified', 'bbonly'], (f)=>
      if (@$("input[name='#{f}']").is(':checked'))
        flags[f] = 1

    @model.set('flags', flags)

  sortOrderChanged: (e)->
    sort = $('option:selected', e.currentTarget).val()
    @model.set('sort', sort)

  initializeDisplayTypeCheckBoxes: ->
    _.each @model.get('location_type'), (filterVal)->
      @$("[data-type='location'][data-id='#{filterVal}']").prop('checked', true)
    _.each @model.get('event_type'), (filterVal)->
      @$("[data-type='event'][data-id='#{filterVal}']").prop('checked', true)

  displayTypeCheckBoxClicked: (e)->
    event_type = _.collect @$("[data-type='event']:checked"), (o)->
      $(o).data('id')
    location_type = _.collect @$("[data-type='location']:checked"), (o)->
      $(o).data('id')
    @model.set({event_type: event_type, location_type: location_type})
 
  search: (e)->
    searchQuery = @$('[name="search"]').val()
    RollFindr.GlobalEvents.trigger('search', {
      query: searchQuery
    })
    e.preventDefault()

  initializePickers: -> 
    icons = {
      time: "fa fa-clock-o",
      date: "fa fa-calendar",
      up: "fa fa-arrow-up",
      down: "fa fa-arrow-down"
    }

    formatIso8601 = "YYYY-MM-DDTHH:mm:ss"

    $('.pick-time').datetimepicker({
      pickTime: false
      sideBySide: true
      useSeconds: false
      useCurrent: false
      icons: icons
      format: formatIso8601
    })

    @startPicker = $('.pick-time.start')
    @endPicker = $('.pick-time.end')

    start = @model.get('event_start')
    end = @model.get('event_end')
    @startPicker.data('DateTimePicker').setDate(start) if start?
    @endPicker.data('DateTimePicker').setDate(end) if end?

    @startPicker.on "dp.change", (e)=>
      @endPicker.data("DateTimePicker").setMinDate(e.date)

    @endPicker.on "dp.change", (e)=>
      @startPicker.data("DateTimePicker").setMaxDate(e.date)

