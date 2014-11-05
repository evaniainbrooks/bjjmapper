//= require backbone/views/map-view

+function($) {
  "use strict";

  RollFindr.Views.LocationShowView = Backbone.View.extend({
    mapView: null,
    addInstructorView: null,
    events: {
      'click .add-instructor': 'addInstructor',
      'click .remove-instructor': 'removeInstructor',
      'change [name="location[team_id]"]': 'changeTeam'
    },
    initialize: function(options) {
      _.bindAll(this, 'addInstructor', 'removeInstructor', 'instructorCollectionChanged', 'changeTeam');

      this.addInstructorView = new RollFindr.Views.AddInstructorView();
      if (undefined !== options.mapModel) {
        var mapModel = new RollFindr.Models.Map(options.mapModel);
        this.mapView = new RollFindr.Views.MapView({model: mapModel, el: this.el});
      }

      this.model = new RollFindr.Models.Location(options.model);
      this.listenTo(this.model.get('instructors'), 'remove', this.instructorCollectionChanged);
    
      this.initializeCalendar();
    },
    initializeCalendar: function() {
      var locationId = this.model.get('id');
      this.$('.scheduler').fullCalendar({
        events: Routes.location_events_path(locationId),
        header: {
          left: 'prev,next today',
          center: 'title',
          right: 'month,basicWeek,basicDay'
        }
      });
    },
    addInstructor: function() {
      $('.add-instructor-dialog').modal('show');
    },
    removeInstructor: function(e) {
      var locationId = this.model.get('id');
      var instructorId = $(e.currentTarget).data('id');

      var instructors = this.model.get('instructors');
      var instructor = instructors.findWhere({id: instructorId});

      if (undefined !== instructor) {
        instructor.destroy({
          success: function() { instructors.remove(instructor); }
        });
      }
    },
    instructorCollectionChanged: function() {
      var locationId = this.model.get('id');
      window.location = Routes.location_path(locationId, {edit: 1});
    },
    changeTeam: function(e) {
      var teamImg = $('option:selected', e.currentTarget).data('img-src');
      var imgElem = this.$('.edit-image');
      
      imgElem.attr('src', teamImg);
    }
  });
}(jQuery);
