class RollFindr.Views.UserStudentsView extends Backbone.View
  model: null
  el: $('.students')
  template: JST['templates/student']
  events: {
    'click .add-student': 'addStudent'
    'click .remove-student': 'removeStudent'
  }
  initialize: ->
    _.bindAll(this, 'render', 'addStudent', 'removeStudent')
    @listenTo(@model.get('lineal_children'), 'add remove sync', @render);
    @model.get('lineal_children').fetch()

  render: ->
    @$('.items').empty()
    @model.get('lineal_children').each (student)=>
      elem = @template({student: student.toJSON()})
      @$('.items').append(elem)

  addStudent: ->
    $('.add-student-dialog').modal('show')

  removeStudent: (e)->
    alert('remove student')

    instructor_id = @model.get('id');
    student_id = $(e.currentTarget).data('id');

    students = @model.get('lineal_children')
    student = students.findWhere({id: student_id})

    student.set('instructor_id', instructor_id)
    student.destroy({
      success: ->
        students.remove(student)
    })

