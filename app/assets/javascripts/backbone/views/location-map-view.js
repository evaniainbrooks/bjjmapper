+function($) {
  "use strict";
  RollFindr.Views.LocationMapView = Backbone.View.extend({
    template: _.template( $('.show-location-template').html() ),
    initialize: function(options) {
      var self = this;
      _.extend(this, _.pick(options, "map"));
      this.setFilters(options.filters);

      this.markers = {};
      this.listenTo(this.collection, 'sync', this.render);
    },
    setFilters: function(filters) {
      if ("undefined" !== typeof(filters) && filters.length > 0) {
        this.filters = _.object(filters.map(function(f) { return [f.get('id'), 1] }));
      } else {
        delete this.filters;
      }
    },
    isFiltered: function(loc) {
      var teamId = loc.get('team_id');
      return "undefined" !== typeof(this.filters) && "undefined" === typeof(this.filters[teamId]);
    },
    render: function() {
      console.log("rendering locations");
      console.log(this.filters);

      var self = this;
      this.collection.each(function(loc) {
        var id = loc.get('id');
        var filtered = self.isFiltered(loc);
        
        if (filtered) {
          console.log("Location " + loc.get('title') + " is filtered");
          if ("undefined" !== typeof(self.markers[id])) {
            console.log("Removing marker for filtered location " + id);
            self.markers[id].setMap(null);
            delete self.markers[id];
          }

          return;
        }

        if ("undefined" !== typeof(self.markers[id])) {
          return;
        }

        self.markers[id] = new google.maps.Marker({
           id: loc.get('id'),
           map: self.map,
           title: loc.get('address'),
           position: new google.maps.LatLng(loc.get('coordinates')[0], loc.get('coordinates')[1]),
           cursor: 'pointer',
           flat: false,
        });

        var infoWindow = new google.maps.InfoWindow();
        infoWindow.setContent(self.template({location: loc.toJSON()}));
        google.maps.event.addListener(self.markers[id], 'click', function() {
          infoWindow.open(self.map, self.markers[id]);
        });
      });
    }
  });

}(jQuery);
