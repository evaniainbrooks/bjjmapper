+function($) {
  "use strict";
  RollFindr.Views.MapViewLocations = Backbone.View.extend({
    template: JST['templates/locations/show'],
    initialize: function(options) {
      var self = this;
      
      this.map = options.map;
      this.setFilters(options.filters);
      this.markers = {};
      this.listenTo(this.model.get('locations'), 'sync', this.render);
    },
    setFilters: function(filters) {
      if ("undefined" !== typeof(filters) && filters.length > 0) {
        this.filters = _.object(filters.map(function(f) { 
          return [f.get('id'), 1] 
        }));
      } else {
        delete this.filters;
      }
    },
    isFiltered: function(loc) {
      var teamId = loc.get('team_id');
      return "undefined" !== typeof(this.filters) && "undefined" === typeof(this.filters[teamId]);
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
    render: function() {
      var self = this;
      this.model.get('locations').each(function(loc) {
        var filtered = self.isFiltered(loc);
        if (filtered) {
          self.deleteMarker(loc);
        } else {
          self.addMarker(loc);
        }
      });
    }
  });

}(jQuery);
