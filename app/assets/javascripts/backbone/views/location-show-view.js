//= require backbone/views/add-instructor-view
//= require backbone/views/schedule-view
//= require backbone/views/location-nearby-view
//= require backbone/views/location-reviews-view
//= require backbone/views/map/map_view

+function($) {
  "use strict";

  RollFindr.Views.LocationShowView = Backbone.View.extend({
    el: $('.show-location'),
    mapView: null,
    addInstructorView: null,
    scheduleView: null,
    reviewsView: null,
    events: {
      'change [name="location[team_id]"]': 'changeTeam',
      'click .add-instructor-menu': 'addInstructor',
      'click .add-event-menu': 'addEvent',
      'click .show-metadata': 'showMetadataDialog'
    },
    initialize: function(options) {
      _.bindAll(this,
        'addInstructor',
        'addEvent',
        'changeTeam',
        'showMetadataDialog');

      this.model = new RollFindr.Models.Location(options.model);
      this.addInstructorView = new RollFindr.Views.AddInstructorView();
      this.scheduleView = new RollFindr.Views.ScheduleView({starting: options.starting, editable: options.editable, model: this.model});
      this.nearbyView = new RollFindr.Views.LocationNearbyView({model: this.model});
      this.instructorsView = new RollFindr.Views.LocationInstructorsView({model: this.model});
      this.reviewsView = new RollFindr.Views.LocationReviewsView({template_name: 'review', location_id: this.model.get('id')});
      if (undefined !== options.mapModel) {
        var mapModel = new RollFindr.Models.Map(options.mapModel);
        this.mapView = new RollFindr.Views.StaticMapView({editable: options.editable, model: mapModel, el: this.$('.map')});
      }
    },
    addInstructor: function() {
      $('.add-instructor-dialog').modal('show');
    },
    addEvent: function() {
      $('.create-event-dialog').modal('show');
    },
    changeTeam: function(e) {
      var teamImg = $('option:selected', e.currentTarget).data('img-src');
      var imgElem = this.$('.edit-image');
      imgElem.attr('src', teamImg);
    },
    showMetadataDialog: function() {
      $('.location-metadata-dialog').modal('show');
    }
  });
}(jQuery);
