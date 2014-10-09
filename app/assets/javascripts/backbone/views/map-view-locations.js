+function($) {
  "use strict";
  RollFindr.Views.MapViewLocations = Backbone.View.extend({
    template: JST['templates/locations/show'],
    initialize: function(options) {
      _.bindAll(this, 'render');

      this.map = options.map;
      this.filters = options.filters;
      this.markers = {};
    },
    addMarker: function(loc) {
      var self = this;
      var id = loc.get('id');
      var markerExists = "undefined" !== typeof(self.markers[id]);
      if (markerExists) {
        return;
      }
      
      self.markers[id] = new google.maps.Marker({
         id: id,
         map: self.map,
         title: loc.get('address'),
         position: new google.maps.LatLng(loc.get('coordinates')[0], loc.get('coordinates')[1]),
         cursor: 'pointer',
         flat: false,
      });

      if (null !== self.template) {
        var infoWindow = new google.maps.InfoWindow();
        infoWindow.setContent(self.template({location: loc.toJSON()}));
        google.maps.event.addListener(self.markers[id], 'click', function() {
          infoWindow.open(self.map, self.markers[id]);
        });
      }
    },
    deleteMarker: function(loc) {
      var id = loc.get('id');
      if ("undefined" !== typeof(this.markers[id])) {
        this.markers[id].setMap(null);
        delete this.markers[id];
      }
    },
    render: function(filters) {
      var self = this;

      var activeFilters = this.filters.activeFilters();
      this.collection.each(function(loc) {
        var teamId = loc.get('team_id');
        var filtered = null !== activeFilters && 1 !== activeFilters[teamId];
        if (filtered) {
          self.deleteMarker(loc);
        } else {
          self.addMarker(loc);
        }
      });
    }
  });

}(jQuery);
