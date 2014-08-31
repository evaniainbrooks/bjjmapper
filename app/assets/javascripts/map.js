+function() {
  "use strict";
  
  var SEATTLE =  new google.maps.LatLng(47.6097, 122.3331);

  function mapDragEndListener(map, event) {
    mapSearchForCurrentView(map, mapDrawMarker);
  }

  function mapEditModeClickListener(map, event) {
    var geocodeUrl = $('.map-canvas').data('geocode-path');
    $.ajax({
      url: geocodeUrl,
      data: {
        location: {
          coordinates: JSON.stringify([event.latLng.lng(), event.latLng.lat()])
        }
      },
      method: 'GET',
      success: function(data) {
        console.log(data);
        
        $('.city', '.new-location-modal').val(data.city);
        $('.state', '.new-location-modal').val(data.state);
        $('.country', '.new-location-modal').val(data.country);
        $('.postal-code', '.new-location-modal').val(data.postal_code);
        $('.street', '.new-location-modal').val(data.street);
        $('.coordinates', '.new-location-modal').val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]));
      }
    });

    $('.new-location-modal').modal('show');
  }

  function mapDrawMarker(map, result, index) {
    var marker = new google.maps.Marker({
       id: result.id,
       map: map,
       title: result.address,
       position: new google.maps.LatLng(result.coordinates[1], result.coordinates[0]),
       cursor: 'pointer',
       flat: false,
    });
   
    var newMapShowTemplate = template('.show-location')[0];
    $('.title', newMapShowTemplate).text(result.title);
    $('.team-name', newMapShowTemplate).text(result.team_name);
    $('.description', newMapShowTemplate).text(result.description);
    $('.coords', newMapShowTemplate).text(result.coordinates);
    $('a.more', newMapShowTemplate).attr('href', Routes.location_path(result.id));

    createInfoWindow(map, newMapShowTemplate, marker);
  }

  function mapSearchForCurrentView(map, locationCallback) {

    var center = map.getCenter();
    var url = $('.map-canvas').data('search-path');

    $.ajax({
      url: url,
      data: {
        viewport: 1,
        center: [center.lat(), center.lng()]
      },
      method: 'GET',
      success: function(data) {
        $.each(data, function(i, result) {
          locationCallback(map, result, i);
        });
      }
    });
  }

  function mapInitialize(element, options) {
    var mapOptions = {
      zoom: options.zoom,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    var map = new google.maps.Map(element, mapOptions);
    
    var editControl = template('.map-edit-control');
    if (editControl.length > 0) {
      google.maps.event.addDomListener(editControl[0], 'click', function() {
        if (!window.userIsAuthenticated()) {
          $('.login-modal').modal('show');
        }
      });
      
      editControl.index = 1;
      map.controls[google.maps.ControlPosition.BOTTOM_RIGHT].push(editControl[0]);
    }

    if (options.geolocate) {
      mapGeoLocate(map, options.center);
    } else {
      mapSetLocation(map, options.center);
    }

    google.maps.event.addListener(map, 'click', function(event) { mapEditModeClickListener(map, event) }); 
    google.maps.event.addListener(map, 'dragend', function(event) { mapDragEndListener(map, event) });
  
    return map;
  }

  function mapGeoLocate(map, defaultLocation) {
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
        return mapSetLocation(map, initialLocation);
      }, function() {
        return mapSetLocation(map, defaultLocation);
      });
    }
  }

  function placeMarker(map, loc) {
    var marker = new google.maps.Marker({
      position: loc, 
      map: map
    });

    return marker;
  }

  function createInfoWindow(map, contentString, marker) {
    var infoWindow = new google.maps.InfoWindow();
    infoWindow.setContent(contentString);
    google.maps.event.addListener(marker, 'click', function() {
      infoWindow.open(map, marker);
    });
    return infoWindow;
  }

  function mapSetLocation(map, initLoc) {
    map.setCenter(initLoc);
    mapSearchForCurrentView(map, mapDrawMarker);
  }

  var defaults = { zoom: 12, center: SEATTLE, geolocate: true };

  $.fn.mapCreate = function(options) {
    var settings = $.extend({}, defaults, options);
    this.each(function(i, o) {
      google.maps.event.addDomListener(window, 'load', function() {
        mapInitialize(o, settings);
      });
    });
  };

}();

