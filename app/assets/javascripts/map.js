var map;

function mapDragEndListener(event) {
  mapSearchForCurrentView(mapDrawMarker);
}

function mapEditModeClickListener(event) {
  var newMapEditTemplate = template('.new-location')[0];
  $('.coordinates', newMapEditTemplate).val(JSON.stringify([event.latLng.lng(), event.latLng.lat()]));

  var marker = placeMarker(map, event.latLng);
  var infoWindow = createInfoWindow(newMapEditTemplate, marker);
  infoWindow.open(map, marker);

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
      
      $('.city', newMapEditTemplate).val(data.city);
      $('.state', newMapEditTemplate).val(data.state);
      $('.country', newMapEditTemplate).val(data.country);
      $('.postal_code', newMapEditTemplate).val(data.postal_code);
      $('.street', newMapEditTemplate).val(data.street);
    }
  });
    
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
  $('.coords', newMapShowTemplate).text(result.coordinates);
  $('a.more', newMapShowTemplate).attr('href', Routes.location_path(result.id));

  createInfoWindow(newMapShowTemplate, marker);
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

function mapInitialize() {
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

function geoLocate() {
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

function createInfoWindow(contentString, marker) {
  var infoWindow = new google.maps.InfoWindow();
  infoWindow.setContent(contentString);
  google.maps.event.addListener(marker, 'click', function() {
    infoWindow.open(map, marker);
  });
  return infoWindow;
}

function mapSetLocation(initLoc) {
  map.setCenter(initLoc);
  mapSearchForCurrentView(mapDrawMarker);
}

google.maps.event.addDomListener(window, 'load', mapInitialize);

