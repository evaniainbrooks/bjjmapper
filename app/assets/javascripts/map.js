var map;

function mapDragEndListener(event) {
  mapSearchForCurrentView(mapDrawMarker);
}

function mapEditModeClickListener(event) {
  var marker = placeMarker(map, event.latLng);
  var newMapEditTemplate = template('.new-location')[0];
  $('.coordinates', newMapEditTemplate).val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]));

  var infoWindow = new google.maps.InfoWindow();
  initInfoWindow(map, infoWindow, newMapEditTemplate, marker);
}

function mapDrawMarker(result, index) {
  var marker = new google.maps.Marker({
     id: result._id,
     map: map,
     title: result.address,
     position: new google.maps.LatLng(result.coordinates[1], result.coordinates[0]),
     cursor: 'pointer',
     flat: false/*,
     icon: new google.maps.MarkerImage('/assets/marker.png',
           new google.maps.Size(32, 35),
           new google.maps.Point(0, 0),
           new google.maps.Point(32 / 2, 35),
           new google.maps.Size(32, 35))*/
  });
  
  var newMapShowTemplate = template('.show-location')[0];
  $('.title', newMapShowTemplate).text(result.title);
  $('.description', newMapShowTemplate).text(result.description);
  $('.coords', newMapShowTemplate).text(result.coords);

  var infoWindow = new google.maps.InfoWindow();
  initInfoWindow(map, infoWindow, newMapShowTemplate, marker);
}

function mapSearchForCurrentView(locationCallback) {

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
        locationCallback(result, i);
      });
    }
  });
}

function initialize() {
  var mapOptions = {
    zoom: 12,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map($('.map-canvas')[0], mapOptions);
  
  var editControl = template('.map-edit-control')[0];
  google.maps.event.addDomListener(editControl, 'click', function() {
    alert("Clicked!");
  });

  editControl.index = 1;
  map.controls[google.maps.ControlPosition.BOTTOM_RIGHT].push(editControl);

  geoLocate();
  google.maps.event.addListener(map, 'click', mapEditModeClickListener); 
  google.maps.event.addListener(map, 'dragend', mapDragEndListener);
}

google.maps.event.addDomListener(window, 'load', initialize);

function geoLocate() {
  // Try W3C Geolocation (Preferred)
  if(navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      var initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
      return mapSetLocation(initialLocation);
    }, function() {
      var SEATTLE =  new google.maps.LatLng(47.6097, 122.3331);
      return mapSetLocation(SEATTLE);
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

function initInfoWindow(map, infoWindow, contentString, marker) {
  google.maps.event.addListener(marker, 'click', function() {
    infoWindow.setContent(contentString);
    infoWindow.open(map, marker);
  });
}

function mapSetLocation(initLoc) {
  map.setCenter(initLoc);
  mapSearchForCurrentView(mapDrawMarker);
}

