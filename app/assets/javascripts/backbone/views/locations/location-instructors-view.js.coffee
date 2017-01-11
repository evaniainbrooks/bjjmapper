class RollFindr.Views.LocationInstructorsView extends Backbone.View
  model: null
  el: $('.instructors')
  template: JST['templates/locations/instructor']
  events: {
    'click .add-instructor': 'addInstructor',
    'click .remove-instructor': 'removeInstructor'
  }
  initialize: ->
    _.bindAll(this, 'render', 'addInstructor', 'removeInstructor')
    this.listenTo(@model.get('instructors'), 'remove sync', @render)
    @model.get('instructors').fetch()

  addInstructor: ->
    $('.add-instructor-dialog').modal('show')

  render: ->
    @$('.items').empty()
    if @model.get('instructors').size() > 0
      @$el.removeClass('empty')
      @model.get('instructors').each (instructor)=>
        elem = @template({user: instructor.toJSON()})
        @$('.items').append(elem)
    else
      @$el.addClass('empty')

  removeInstructor: (e)->
    locationId = @model.get('id')
    instructorId = $(e.currentTarget).data('id')

    instructors = @model.get('instructors')
    instructor = instructors.findWhere({id: instructorId})

    if instructor?
      instructor.set('location_id', locationId)
      instructor.destroy({
        success: ->
          instructors.remove(instructor)
      })

