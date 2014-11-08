+function($) {
  "use strict";
  RollFindr.Views.MapViewLocations = Backbone.View.extend({
    template: JST['templates/locations/show'],
    initialize: function(options) {
      _.bindAll(this, 'render');

      this.listenTo(this.collection, 'reset', this.render);

      this.map = options.map;
      this.markers = {};
    },
    infoWindow: null,
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
        this.infoWindow = new google.maps.InfoWindow();
        google.maps.event.addListener(self.markers[id], 'click', function() {
          self.infoWindow.setContent(self.template({location: loc.toJSON()}));
          self.infoWindow.open(self.map, self.markers[id]);
        });
      }
    },
    deleteMarker: function(id) {
      //var id = loc.get('id');
      if ("undefined" !== typeof(this.markers[id])) {
        this.markers[id].setMap(null);
        delete this.markers[id];
      }
    },
    render: function() {
      var self = this;
      var newMarkerSet = {};
      this.collection.each(function(loc) {
        self.addMarker(loc);
        newMarkerSet[loc.get('id')] = 1;
      });

      for (var marker in this.markers) {
        // TODO: Don't delete markers we are just going to add again
        var markerStillExists = newMarkerSet[marker]; 
        if (!markerStillExists) {
          self.deleteMarker(marker);
        }
      }
    }
  });

}(jQuery);
