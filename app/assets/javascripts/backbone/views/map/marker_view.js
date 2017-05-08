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
    template: function(loc) {
      if (loc.get('loctype') == RollFindr.Models.Location.LOCATION_TYPE_ACADEMY) {
        return JST['templates/map/academy-info-window'];
      } else {
        return JST['templates/map/event-info-window'];
      }
    },
    initialize: function(options) {
      _.bindAll(this, 'render', 'getMarkerId', 'activeMarkerChanged', 'markerDragEnd');

      this.listenTo(this.model, 'reset', this.render);

      this.draggable = options.editable;
      this.map = options.map;
      this.markers = {};
      this.idFactory = new IdFactory();
      if (options.template) {
        this.template = options.template;
      }

      RollFindr.GlobalEvents.on('markerActive', this.activeMarkerChanged);
    },
    infoWindow: new google.maps.InfoWindow(),
    getMarkerId: function(loc_id) {
      if (this.markers[loc_id]) {
        return this.markers[loc_id].marker_id;
      } else {
        return null;
      }
    },
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
      position = new google.maps.LatLng(loc.get('lat'), loc.get('lng'));

      marker = new RichMarker({
         id: id,
         map: self.map,
         position: position,
         anchor: RichMarkerPosition.MIDDLE,
         content: self.getMarkerContent(loc),
         draggable: self.draggable,
         cursor: 'pointer',
         shadow: false,
         flat: false,
      });

      if (self.draggable) {
        google.maps.event.addListener(marker, 'dragend', self.markerDragEnd);
      }

      self.markers[id] = {
        marker_id: loc.get('marker_id'),
        marker: marker
      };

      google.maps.event.addListener(self.markers[id].marker, 'click', function() {
        RollFindr.GlobalEvents.trigger('markerActive', {id: id});
      });
    },
    getMarkerContent: function(loc) {
      var markerContent = $('<div></div>');
      var markerInnerContent = $('<div></div>')

      markerInnerContent.addClass('map-label-content');
      markerInnerContent.addClass(loc.getColor());
      markerInnerContent.addClass(loc.getStatusClass());
      markerInnerContent.text(loc.get('marker_id').toString());

      markerContent.html(markerInnerContent);

      return markerContent.html();
    },
    markerDragEnd: function(e) {
      var model = this.model.get('locations').models[0];
      var id = model.get('id');
      var address = model.get('address');
      RollFindr.ConfirmDialog({
        url: Routes.move_location_path(id, { lat: e.position.lat(), lng: e.position.lng() }),
        returnto: Routes.location_path(id, { success: 1 }),
        method: 'POST',
        type: 'warning',
        title: 'Are you sure you want to move this academy?',
        body: "Note that this action cannot be un-done. This will clear the current address of <b>" + address + "</b> and a new address will be calculated based on the new coordinates. Please proceed with caution."
      });
    },
    openInfoWindow: function(loc) {
      var self = this;
      var template = self.template(loc);
      var content = template({location: loc.toJSON()});

      self.infoWindow.setContent(content);
      self.infoWindow.open(self.map, self.markers[loc.get('id')].marker);
      
      window.generateAvatars($('[data-avatar-placeholder]', '.show-location-overlay'));
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
        var loc = this.model.get('locations').findWhere({id: e.id});
        this.openInfoWindow(loc);
      } else {
        this.infoWindow.close();
      }
    },
    render: function() {
      var self = this;
      var newMarkers = {};
      this.model.get('locations').each(function(loc) {
        self.addMarker(loc);
        newMarkers[loc.get('id')] = 1;
      });
      
      var bounds = new google.maps.LatLngBounds();
      for (var marker in this.markers) {
        if (!newMarkers[marker]) {
          self.deleteMarker(marker);
        } else {
          bounds.extend(this.markers[marker].marker.getPosition());
        }
      }

      if (this.markers.length > 1) {
        this.map.fitBounds(bounds);
      }
    }
  });

}(jQuery);
