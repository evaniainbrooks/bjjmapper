+function($) {
  "use strict";

  RollFindr.Views.MapView = Backbone.View.extend({
    tagName: 'div',
    map: null,
    teamListFilterView: null,
    initialize: function() {
      _.bindAll(this, 'createLocation');

      this.activate();
    },
    activate: function() {
      var center = this.model.get('center');
      var mapOptions = {
        zoom: this.model.get('zoom'),
        mapTypeId: google.maps.MapTypeId.ROADMAP
      };

      this.map = new google.maps.Map(this.el, mapOptions);

      var map = this.map;      
      var shouldGeolocate = this.model.get('geolocate');
      if (shouldGeolocate && navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
          var initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
          map.setCenter(initialLocation);
        }, function() {
          this.setDefaultCenter();
        });
      } else {
        this.setDefaultCenter();
      }

      google.maps.event.addListener(this.map, 'click', this.createLocation);
      this.teamListFilterView = new RollFindr.Views.TeamListView();
      this.map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(this.teamListFilterView.el);
      /*    $('body').delegate('input[data-team-id]', 'change', function(e) {
           map.teamFilter = [];
           $('input[data-team-id]:checked').each(function(i, o) {
             map.teamFilter.push($(o).data('team-id'));
            });
          mapPopulateView(map, element, mapDrawMarker, true); 
       });
     }

    */

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
    }
  });
    
}(jQuery);
