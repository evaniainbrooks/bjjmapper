+function($) {
  "use strict";

  RollFindr.Views.TeamListView = Backbone.View.extend({
    template: _.template( $('.team-list-template').html() ),
    initialize: function() {
      var self = this;
      
      this.collection = new RollFindr.Collections.TeamsCollection();
      this.collection.fetch().done(function() {
        self.render();
      });
    },
    render: function() {
      this.$el.append( this.template({teams: this.collection.toJSON() }) );
    }
  });

} (jQuery);
