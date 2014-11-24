+function($) {
  "use strict";

  RollFindr.Views.TeamListView = Backbone.View.extend({
    template: JST['templates/teams/index'],
    events: {
      'click [type="checkbox"]': 'changeFilter',
      'click a[data-clear-filters]': 'clearFilters'
    },
    initialize: function() {
      var self = this;

      _.bindAll(this, 'changeFilter', 'clearFilters');

      this.collection = new RollFindr.Collections.TeamsCollection();
      this.collection.fetch({silent: true, success: function() {
        self.render();
      }, error: function() {
        toastr.error('Failed to fetch filters');
      }});
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
      var filters = _.chain(this.collection.models)
        .filter(function(f) {
          return f.get('filter-active');
        })
        .map(function(f) {
          return [f.get('id'), 1];
        });

      if (filters.value().length <= 0) {
        return null;
      }

      return _.object(filters.value());
    },
    filterCollection: function(collectionToFilter) {
      var activeFilters = this.activeFilters();
      if (null == activeFilters) {
        return collectionToFilter;
      }

      return collectionToFilter.filter(function(f) {
        var teamId = f.get('team_id');
        return "undefined" !== typeof(activeFilters[teamId]);
      });
    },
    clearFilters: function() {
      this.$('input:checked').each(function(i, o) {
        $(o).removeAttr('checked');
      });

      this.collection.each(function(f) {
        f.set('filter-active', null, {silent: true});
      });

      this.collection.trigger('sync');
    }
  });

} (jQuery);
