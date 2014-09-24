+function($) {
  "use strict";

  RollFindr.Views.TeamListView = Backbone.View.extend({
    template: null,
    events: {
      'click [type="checkbox"]': 'changeFilter'
    },
    initialize: function() {
      var self = this;

      _.bindAll(this, 'changeFilter');

      var templateContent = $('.team-list-template');
      if (templateContent.length > 0) {
        this.template = _.template( templateContent.html() );
      }
      this.collection = new RollFindr.Collections.TeamsCollection();
      this.collection.fetch({silent: true}).done(function() {
        self.render();
      });
    },
    render: function() {
      if (null !== this.template) {
        this.$el.append( this.template({teams: this.collection.sortByField('name').toJSON() }) );
      }
    },
    changeFilter: function(e) {
      var teamId = $(e.target).data('team-id');
      var filter = this.collection.where({id: teamId})[0];
      filter.set('filter-active', $(e.target).is(':checked'));
    },
    activeFilters: function() {
      var filteredCollection = this.collection.filter(function(f) {
        return f.get('filter-active');
      });
      return filteredCollection;
    }
  });

} (jQuery);
