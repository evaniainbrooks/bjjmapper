+function() {
  "use strict";
  
  var SEATTLE =  new google.maps.LatLng(47.6097, 122.3331);

  function greatCircleDistance(map) {
    var bounds = map.getBounds();
    if ("undefined" === typeof bounds) {
      return null;
    }

    var center = bounds.getCenter();
    var ne = bounds.getNorthEast();
    var r = 3963.0;  
    var lat1 = center.lat().toRad();
    var lon1 = center.lng().toRad();
    var lat2 = ne.lat().toRad();
    var lon2 = ne.lng().toRad();

    // distance = circle radius from center to Northeast corner of bounds
    return r * Math.acos(Math.sin(lat1) * Math.sin(lat2) + 
      Math.cos(lat1) * Math.cos(lat2) * Math.cos(lon2 - lon1));
  }

  function mapDragEndListener(map, element, event) {
    mapSearchForCurrentView(map, element, mapDrawMarker);
  }

  function mapEditModeClickListener(map, element, event) {
    var geocodeUrl = $(element).data('geocode-path');
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

    map.markers.push(marker);
   
    var newMapShowTemplate = template('.show-location')[0];
    $('.title', newMapShowTemplate).text(result.title);
    $('.team-name', newMapShowTemplate).text(result.team_name);
    $('.description', newMapShowTemplate).text(result.description);
    $('.coords', newMapShowTemplate).text(result.coordinates);
    $('a.more', newMapShowTemplate).attr('href', Routes.location_path(result.id));
    $('.updated-at', newMapShowTemplate).text(result.updated_at)

    createInfoWindow(map, newMapShowTemplate, marker);
  }

  function mapClearMarkers(map) {
    for (var i = 0; i < map.markers.length; ++i) {
      map.markers[i].setMap(null);
    }

    map.markers = [];
  }

  function mapSearchForCurrentView(map, element, locationCallback) {

    var center = map.getCenter();
    var url = $(element).data('search-path');
    var distance = greatCircleDistance(map);

    $.ajax({
      url: url,
      data: {
        team: map.teamFilter,
        viewport: 1,
        distance: distance, 
        center: [center.lat(), center.lng()]
      },
      method: 'GET',
      success: function(data) {
        mapClearMarkers(map);
        if (typeof data !== "undefined") {
          $.each(data, function(i, result) {
            locationCallback(map, result, i);
          });
        }
      }
    });
  }

  function createControls(map, element, options) {
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

    var teamList = template('.map-team-list');
    if (teamList.length > 0) {
      teamList.index = 1;
      map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(teamList[0]);
      $('body').delegate('input[data-team-id]', 'change', function(e) {
        
        // TODO: Why can't use map here?
        map.teamFilter = [];
        $('input[data-team-id]:checked').each(function(i, o) {
          map.teamFilter.push($(o).data('team-id'));
        });

        mapSearchForCurrentView(map, element, mapDrawMarker); 
      });
    }
  }

  function mapInitialize(element, options) {
    var mapOptions = {
      zoom: options.zoom,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    
    var map = new google.maps.Map(element, mapOptions);
    map.markers = [];
    createControls(map, element);


    var center = new google.maps.LatLng(options.center[0], options.center[1]); 
    if (options.geolocate) {
      mapGeoLocate(map, element, center);
    } else {
      mapSetLocation(map, element, center);
    }

    google.maps.event.addListener(map, 'click', function(event) { mapEditModeClickListener(map, element, event) }); 
    google.maps.event.addListener(map, 'dragend', function(event) { mapDragEndListener(map, element, event) });
  
    return map;
  }

  function mapGeoLocate(map, element, defaultLocation) {
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
        return mapSetLocation(map, element, initialLocation);
      }, function() {
        return mapSetLocation(map, element, defaultLocation);
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

  function mapSetLocation(map, element, initLoc) {
    map.setCenter(initLoc);
    mapSearchForCurrentView(map, element, mapDrawMarker);
  }

  var defaults = { editable: false, zoom: 12, center: SEATTLE, geolocate: false };

  $(document).ready(function() {
    $('div.map-canvas').each(function(i, o) {
      var $o = $(o);
      var options = {
        geocodepath: $o.data('geocode-path'),
        searchpath: $o.data('search-path'),
        createpath: $o.data('create-path'),
        geolocate: $o.data('geolocate'),
        zoom: $o.data('zoom'),
        center: $o.data('center'),
        editable: $o.data('editable')
      };

      var settings = $.extend({}, defaults, options);
      mapInitialize(o, settings);
    });
  });
}();

