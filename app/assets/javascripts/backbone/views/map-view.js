+function($) {
  "use strict";

  RollFindr.Views.MapView = Backbone.View.extend({
    tagName: 'div',
    map: null,
    locations: new RollFindr.Collections.LocationsCollection(),
    teamFilter: null,
    locationsView: null,
    initialize: function() {
      _.bindAll(this, 'createLocation', 'fetchViewport', 'updateFilter');
      
      this.teamFilter = new RollFindr.Views.TeamListView();
      var mapOptions = {
        zoom: this.model.get('zoom'),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };
      this.map = new google.maps.Map(this.el, mapOptions);
      this.locationsView = new RollFindr.Views.LocationMapView({map: this.map, collection: this.locations});
      this.listenTo(this.teamFilter.collection, 'sync change:filter-active', this.updateFilter);
      
      google.maps.event.addListener(this.map, 'click', this.createLocation);
      google.maps.event.addListener(this.map, 'idle', this.fetchViewport);
      
      this.map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(this.teamFilter.el);
      
      this.setCenter();
    },
    updateFilter: function() {
      this.locationsView.setFilters(this.teamFilter.activeFilters());
      this.locationsView.render();
    },
    createLocation: function(event) {
      $('.coordinates', '.new-location-modal').val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]));
      $('.new-location-modal').modal('show');
    },
    setCenter: function() {
      var self = this;
      var shouldGeolocate = this.model.get('geolocate');
      if (shouldGeolocate && navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
          var initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
          self.map.setCenter(initialLocation);
        }, function() {
          this.setDefaultCenter();
        });
      } else {
        this.setDefaultCenter();
      }
    },
    setDefaultCenter: function() {
      var defaultCenter = this.model.get('center');
      var defaultLocation = new google.maps.LatLng(defaultCenter[0], defaultCenter[1]);
      this.map.setCenter(defaultLocation);
    },
    fetchViewport: function() {
      var center = this.model.get('center');
      center[0] = this.map.getCenter().lat();
      center[1] = this.map.getCenter().lng();
      this.model.set('center', center);
      this.locations.fetch({remove: false, data: {center: center}});
    }
  });
    
}(jQuery);
