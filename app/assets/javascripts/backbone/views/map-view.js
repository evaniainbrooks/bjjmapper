//= require backbone/views/team-list-view 
+function($) {
  "use strict";

  var circleDistance = function(p0, p1) {
    var center = p0;
    var ne = p1;
    var r = 3963.0;  
    var lat1 = center.lat().toRad();
    var lon1 = center.lng().toRad();
    var lat2 = ne.lat().toRad();
    var lon2 = ne.lng().toRad();
    
    return r * Math.acos(Math.sin(lat1) * Math.sin(lat2) + 
        Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1));
  }

  RollFindr.Views.MapView = Backbone.View.extend({
    tagName: 'div',
    map: null,
    locations: new RollFindr.Collections.LocationsCollection(),
    template: JST['templates/locations/map-list'],
    teamFilter: null,
    locationsView: null,
    initialize: function() {
      _.bindAll(this, 'createLocation', 'fetchViewport', 'updateLocationList', 'updateFilter');
      
      var mapOptions = {
        zoom: this.model.get('zoom'),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      var mapCanvas = $('.map-canvas', this.el)[0];
      this.map = new google.maps.Map(mapCanvas, mapOptions);
      this.locationsView = new RollFindr.Views.MapViewLocations({map: this.map, collection: this.locations});
      
      var shouldFilter = this.model.get('filters');
      if (1 === shouldFilter) {
        this.teamFilter = new RollFindr.Views.TeamListView();
        this.listenTo(this.teamFilter.collection, 'sync change:filter-active', this.updateFilter);
        this.map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(this.teamFilter.el);
      }
      
      this.listenTo(this.locations, 'sync', this.updateLocationList);

      google.maps.event.addListener(this.map, 'click', this.createLocation);
      google.maps.event.addListener(this.map, 'idle', this.fetchViewport);
      
      this.setCenter();
    },
    updateLocationList: function() {
      var self = this;
      var list = self.template({'locations': this.locations.toJSON()}); 
      $('.location-list', this.el).html(list);  
    },
    updateFilter: function() {
      this.locationsView.setFilters(this.teamFilter.activeFilters());
      this.locationsView.render();
    },
    createLocation: function(event) {
      $('.coordinates', '.new-location-dialog').val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]));
      $('.new-location-dialog').modal('show');
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

      var distance = circleDistance(this.map.getCenter(), this.map.getBounds().getNorthEast());

      this.model.set('center', center);
      this.locations.fetch({remove: false, data: {center: center, distance: distance}});
    }
  });
    
}(jQuery);
