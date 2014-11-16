+function($) {
  "use strict";
  RollFindr.Views.MapViewLocations = Backbone.View.extend({
    template: JST['templates/locations/show'],
    initialize: function(options) {
      _.bindAll(this, 'render', 'activeMarkerChanged');

      this.listenTo(this.collection, 'reset', this.render);

      this.map = options.map;
      this.markers = {};
      this.markerCount = 0;

      RollFindr.GlobalEvents.on('markerActive', this.activeMarkerChanged)
    },
    infoWindow: new google.maps.InfoWindow(),
    addMarker: function(loc, index) {
      var self = this;
      var id = loc.get('id');
      var icon;
      var position;
      var markerExists = "undefined" !== typeof(self.markers[id]);
      if (markerExists) {
        return;
      }

      loc.attributes['marker_id'] = ++this.markerCount;
      icon = "/assets/markers/number_" + this.markerCount + ".png";
      position = new google.maps.LatLng(loc.get('coordinates')[0], loc.get('coordinates')[1]),
      self.markers[id] = new google.maps.Marker({
         id: id,
         map: self.map,
         title: loc.get('address'),
         position: position,
         icon: icon,
         cursor: 'pointer',
         flat: false,
      });

      if (null !== self.template) {
        google.maps.event.addListener(self.markers[id], 'click', function() {
          RollFindr.GlobalEvents.trigger('markerActive', {id: id});
        });
      }
    },
    openInfoWindow: function(loc) {
      var self = this;
      self.infoWindow.setContent(self.template({location: loc.toJSON()}));
      self.infoWindow.open(self.map, self.markers[loc.get('id')]);
    },
    deleteMarker: function(id) {
      if ("undefined" !== typeof(this.markers[id])) {
        this.markers[id].setMap(null);
        delete this.markers[id];
        --this.markerCount;
      }
    },
    activeMarkerChanged: function(e) {
      var loc = this.collection.findWhere({id: e.id});
      this.openInfoWindow(loc);
    },
    render: function() {
      var self = this;
      var newMarkers = {};
      this.collection.each(function(loc) {
        self.addMarker(loc);
        newMarkers[loc.get('id')] = 1;
      });
      for (var marker in this.markers) {
        if (!newMarkers[marker]) {
          self.deleteMarker(marker);
        }
      }
    }
  });

}(jQuery);
