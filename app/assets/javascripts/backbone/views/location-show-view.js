//= require backbone/views/add-instructor-view
//= require backbone/views/calendar-view
//= require backbone/views/location-nearby-view
//= require backbone/views/reviews-view
//= require backbone/views/map/map_view

+function($) {
  "use strict";

  RollFindr.Views.LocationShowView = Backbone.View.extend({
    mapView: null,
    addInstructorView: null,
    calendarView: null,
    reviewsView: null,
    events: {
      'click .add-review': 'addReview',
      'change [name="location[team_id]"]': 'changeTeam',
      'click .add-instructor-menu': 'addInstructor'
    },
    initialize: function(options) {
      _.bindAll(this,
        'addReview',
        'addInstructor',
        'changeTeam');

      this.model = new RollFindr.Models.Location(options.model);
      this.addInstructorView = new RollFindr.Views.AddInstructorView();
      this.calendarView = new RollFindr.Views.CalendarView({editable: options.editable, model: this.model});
      this.nearbyView = new RollFindr.Views.LocationNearbyView({model: this.model});
      this.instructorsView = new RollFindr.Views.LocationInstructorsView({model: this.model});
      this.reviewsView = new RollFindr.Views.ReviewsView({template_name: 'review', model: this.model});
      if (undefined !== options.mapModel) {
        var mapModel = new RollFindr.Models.Map(options.mapModel);
        this.mapView = new RollFindr.Views.MapView({editable: options.editable, model: mapModel, el: this.el});
      }
    },
    addInstructor: function() {
      $('.add-instructor-dialog').modal('show');
    },
    addReview: function() {
      $('.add-review-dialog').modal('show');
    },
    changeTeam: function(e) {
      var teamImg = $('option:selected', e.currentTarget).data('img-src');
      var imgElem = this.$('.edit-image');
      imgElem.attr('src', teamImg);
    }
  });
}(jQuery);
