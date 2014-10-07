
+function($) {
  "use strict";

  RollFindr.Views.AddInstructorView = Backbone.View.extend({
    el: $('.add-instructor-dialog'),
    events: {
      'change [name="instructor_name"]': 'changeInstructor'
      //'click button.
    },
    initialize: function() {
      _.bindAll(this, 'changeInstructor');
    },
    changeInstructor: function(e) {
      var selected = $('option:selected', e.currentTarget);
      var img = selected.data('img-src');
      var imgElem = this.$('img');

      imgElem.attr('src', img);
    }
  });
}(jQuery);
