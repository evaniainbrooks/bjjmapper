+function($) {
  "use strict";

  var IdFactory = function() {
    return {
      markerCount: 0,
      idQueue: [],
      nextId: function() {
        if (this.idQueue.length > 0) {
          return this.idQueue.shift();
        } else {
          return ++this.markerCount;
        }
      },
      reclaimId: function(id) {
        this.idQueue.push(id);
        if (this.idQueue.length == this.markerCount) {
          this.markerCount = 0;
          this.idQueue = [];
        }
      },
    }
  };

  RollFindr.Views.MapViewLocations = Backbone.View.extend({
    template: JST['templates/locations/show'],
    initialize: function(options) {
      _.bindAll(this, 'render', 'activeMarkerChanged');

      this.listenTo(this.collection, 'reset', this.render);

      this.map = options.map;
      this.markers = {};
      this.idFactory = new IdFactory();

      RollFindr.GlobalEvents.on('markerActive', this.activeMarkerChanged);
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

      loc.attributes['marker_id'] = this.idFactory.nextId();
      icon = "/assets/markers/number_" + loc.get('marker_id') + ".png";
      position = new google.maps.LatLng(loc.get('coordinates')[0], loc.get('coordinates')[1]),
      self.markers[id] = {
        marker_id: loc.get('marker_id'),
        marker: new google.maps.Marker({
           id: id,
           map: self.map,
           title: loc.get('address'),
           position: position,
           icon: icon,
           cursor: 'pointer',
           flat: false,
        })
      };

      if (null !== self.template) {
        google.maps.event.addListener(self.markers[id].marker, 'click', function() {
          RollFindr.GlobalEvents.trigger('markerActive', {id: id});
        });
      }
    },
    openInfoWindow: function(loc) {
      var self = this;
      self.infoWindow.setContent(self.template({location: loc.toJSON()}));
      self.infoWindow.open(self.map, self.markers[loc.get('id')].marker);
    },
    deleteMarker: function(id) {
      if ("undefined" !== typeof(this.markers[id])) {
        this.markers[id].marker.setMap(null);
        this.idFactory.reclaimId(this.markers[id].marker_id);
        delete this.markers[id].marker;
        delete this.markers[id];
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
