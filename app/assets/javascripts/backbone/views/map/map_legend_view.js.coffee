class RollFindr.Views.MapLegendView extends Backbone.View
  el: $('.wrapper')
  template: JST['templates/map/map_legend']
  events: {
    'click [type="checkbox"]': 'checkBoxClicked'
    'click .close-btn': 'toggleCollapse'
    'click .open-btn': 'toggleCollapse'
  }
  location_type: []
  event_type: []
  initialize: (options)->
    _.bindAll(this,
      'render',
      'toggleCollapse',
      'checkBoxClicked')

    @map = options.map
    @render()

  checkBoxClicked: (e)->
    @event_type = _.collect @$("[data-type='event']:checked"), (o)->
      $(o).data('id')
    @location_type = _.collect @$("[data-type='location']:checked"), (o)->
      $(o).data('id')
    @model.set({event_type: @event_type, location_type: @location_type})

  toggleCollapse: ->
    $('.map-legend').toggleClass('collapsed')

  render: ->
    legend = @template(location_type: @model.get('location_type'), event_type: @model.get('event_type'))
    @map.controls[google.maps.ControlPosition.TOP_RIGHT].push($(legend)[0])
    @delegateEvents()
