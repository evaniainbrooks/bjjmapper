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

  RollFindr.Views.MapMarkerView = Backbone.View.extend({
    template: JST['templates/locations/show'],
    initialize: function(options) {
      _.bindAll(this, 'render', 'activeMarkerChanged', 'markerDragEnd');

      this.listenTo(this.collection, 'reset', this.render);

      this.draggable = options.editable;
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
      var marker;
      var markerExists = "undefined" !== typeof(self.markers[id]);
      if (markerExists) {
        return;
      }

      loc.attributes['marker_id'] = this.idFactory.nextId();
      icon = "/assets/markers/number_" + loc.get('marker_id') + ".png";
      position = new google.maps.LatLng(loc.get('coordinates')[0], loc.get('coordinates')[1]),
      marker = new google.maps.Marker({
         id: id,
         map: self.map,
         title: loc.get('address'),
         position: position,
         icon: icon,
         draggable: self.draggable,
         cursor: 'pointer',
         flat: false,
      });

      if (self.draggable) {
        google.maps.event.addListener(marker, 'dragend', self.markerDragEnd);
      }

      self.markers[id] = {
        marker_id: loc.get('marker_id'),
        marker: marker
      };

      if (null !== self.template) {
        google.maps.event.addListener(self.markers[id].marker, 'click', function() {
          RollFindr.GlobalEvents.trigger('markerActive', {id: id});
        });
      }
    },
    markerDragEnd: function(e) {
      var model = this.collection.models[0];
      var id = model.get('id');
      var address = model.get('address');
      RollFindr.ConfirmDialog({
        url: Routes.move_location_path(id, { lat: e.latLng.lat(), lng: e.latLng.lng() }),
        return_to: Routes.location_path(id, { success: 1 }),
        method: 'POST',
        type: 'warning',
        title: 'Are you sure you want to move this academy?',
        body: "Note that this action cannot be un-done. This will clear the current address of <b>" + address + "</b> and a new address will be calculated based on the new coordinates. Please proceed with caution."
      });
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
    destroy: function() {
      for (var marker in this.markers) {
        this.deleteMarker(marker);
      }
      
      this.undelegateEvents();
      RollFindr.GlobalEvents.off('markerActive', this.activeMarkerChanged);
    },
    activeMarkerChanged: function(e) {
      if (null !== e.id) {
        var loc = this.collection.findWhere({id: e.id});
        this.openInfoWindow(loc);
      } else {
        this.infoWindow.close();
      }
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
