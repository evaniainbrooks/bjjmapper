+function($) {
  "use strict";

  RollFindr.Views.TeamListView = Backbone.View.extend({
    template: _.template( $('.team-list-template').html() ),
    events: {
      'click [type="checkbox"]': 'changeFilter'
    },
    initialize: function() {
      var self = this;

      _.bindAll(this, 'changeFilter');
      
      this.collection = new RollFindr.Collections.TeamsCollection();
      this.collection.fetch().done(function() {
        self.render();
      });
    },
    render: function() {
      this.$el.append( this.template({teams: this.collection.sortByField('name').toJSON() }) );
    },
    changeFilter: function(e) {
      var teamId = $(e.target).data('team-id');
      var filters = this.model.get('filters');
      if ($(e.target).is(':checked')) {
        filters[teamId] = 1;
      } else {
        delete filters[teamId];
      }
      this.model.set('filters', filters);
      console.log(filters);
    }
  });

} (jQuery);
