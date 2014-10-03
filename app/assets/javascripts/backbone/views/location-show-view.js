//= require backbone/views/map-view

+function($) {
  "use strict";

  RollFindr.Views.LocationShowView = Backbone.View.extend({
    mapView: null,
    events: {
      'click .add-instructor': 'addInstructor'
    },
    initialize: function(options) {
      _.bindAll(this, 'addInstructor');

      if (undefined !== options.mapModel) {
        var mapModel = new RollFindr.Models.Map(options.mapModel);
        this.mapView = new RollFindr.Views.MapView({model: mapModel, el: this.el});
      }

      this.model = new RollFindr.Models.Location(options.model);
    },
    addInstructor: function() {
      var locationId = this.model.get('id');
      var newUserModel = new RollFindr.Models.Instructor({location_id: locationId});
      newUserModel.set('instructor_id', '541b9672afd99446c9000031');
      newUserModel.save();
    }
  });
}(jQuery);
