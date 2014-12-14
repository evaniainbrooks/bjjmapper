class RollFindr.Views.LocationInstructorsView extends Backbone.View
  model: null
  el: $('.instructors')
  template: JST['templates/locations/instructor']
  events: {
    'click .remove-instructor': 'removeInstructor'
  }
  initialize: ->
    _.bindAll(this, 'render', 'removeInstructor')
    this.listenTo(@model.get('instructors'), 'remove add', @render);
    @model.get('instructors').fetch().done(@render)

  render: ->
    @$('.items').empty()
    @model.get('instructors').each (instructor)=>
      elem = @template({instructor: instructor.toJSON()})
      @$('.items').append(elem)

  removeInstructor: (e)->
    locationId = @model.get('id');
    instructorId = $(e.currentTarget).data('id');

    instructors = @model.get('instructors');
    instructor = instructors.findWhere({id: instructorId});

    instructor.set('location_id', locationId)
    instructor.destroy({
      success: ->
        instructors.remove(instructor)
    }) if instructor?

