
+function($) {
  "use strict";

  RollFindr.Views.AddInstructorView = Backbone.View.extend({
    el: $('.add-instructor-dialog'),
    events: {
      'change .instructor-name': 'changeInstructor'
    },
    initialize: function() {
      _.bindAll(this, 'changeInstructor');
    },
    changeInstructor: function(e) {
      var selected = $('option:selected', e.currentTarget);
      var img = selected.data('img-src');
      var imgElem = this.$('img');

      if ("undefined" !== typeof(img) && img.length > 0) {
        imgElem.attr('src', img);
      } else {
        var defaultSrc = imgElem.data('default-src');
        imgElem.attr('src', defaultSrc);
      }
    }
  });
}(jQuery);
