+function($) {
  "use strict";

  RollFindr.Views.MapView = Backbone.View.extend({
    tagName: 'div',
    map: null,
    teamListFilterView: null,
    initialize: function() {
      _.bindAll(this, 'createLocation', 'drawLocations', 'fetchViewport');

      this.locations = new RollFindr.Collections.LocationsCollection();
      this.listenTo(this.model, 'change', function() { alert('model changed'); });// TODO: This isn't working
      this.listenTo(this.locations, 'sync', this.drawLocations);

      this.activate();
    },
    activate: function() {
      var self = this;
      var center = this.model.get('center');
      var mapOptions = {
        zoom: this.model.get('zoom'),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      this.map = new google.maps.Map(this.el, mapOptions);

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

      google.maps.event.addListener(this.map, 'click', this.createLocation);
      google.maps.event.addListener(this.map, 'idle', this.fetchViewport);
      
      this.teamListFilterView = new RollFindr.Views.TeamListView({model: this.model});
      this.map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(this.teamListFilterView.el);
    
    },
    events: {
      //'click': 'createLocation'
    },
    createLocation: function(event) {
      $('.coordinates', '.new-location-modal').val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]));
      $('.new-location-modal').modal('show');
    },
    setDefaultCenter: function() {
      var defaultCenter = this.model.get('center');
      var defaultLocation = new google.maps.LatLng(defaultCenter[0], defaultCenter[1]);
      this.map.setCenter(defaultLocation);
    },
    drawLocations: function() {
      console.log('drawLocations');
      var self = this;
      this.locations.each(function(loc) {
        var marker = new google.maps.Marker({
           id: loc.get('id'),
           map: self.map,
           title: loc.get('address'),
           position: new google.maps.LatLng(loc.get('coordinates')[0], loc.get('coordinates')[1]),
           cursor: 'pointer',
           flat: false,
        });

        var infoWindow = new google.maps.InfoWindow();
        infoWindow.setContent(loc.get('title'));
        google.maps.event.addListener(marker, 'click', function() {
          infoWindow.open(self.map, marker);
        });

        //map.markers.push(marker);
        //var newMapShowTemplate = Template.create('show-location', result);
        //createInfoWindow(map, newMapShowTemplate[0], marker);
        //console.log(l);
      });
    },
    fetchViewport: function() {
      console.log('fetchViewport');
      var center = this.model.get('center');
      center[0] = this.map.getCenter().lat();
      center[1] = this.map.getCenter().lng();
      this.model.set('center', center);
      this.locations.fetch({data: {center: center}});
    }
  });
    
}(jQuery);
