// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require openid-jquery
//= require openid-en
//= require openid-init
//= require_tree .
//= require_self

var map;
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
  google.maps.event.addListener(map, 'click', function(event) {
    var marker = placeMarker(map, event.latLng);
    var infoWindow = new google.maps.InfoWindow();
    initInfoWindow(map, infoWindow, "Marker", marker);
  });


  $.ajax({
    url: 'search/test',
    data: { 
      q: 'test'
    },
    method: 'GET',
    success: function(data) {
      $.each(data, function(i, result) {
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

        var infoWindow = new google.maps.InfoWindow();
        initInfoWindow(map, infoWindow, "Marker", marker);
      });
    }
  });
}

google.maps.event.addDomListener(window, 'load', initialize);

function geoLocate() {
  // Try W3C Geolocation (Preferred)
  if(navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      var initialLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
      return setInitialLocation(initialLocation);
    }, function() {
      var NYC =  new google.maps.LatLng(40.69847032728747, -73.9514422416687);
      return setInitialLocation(NYC);
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

function setInitialLocation(initLoc) {
  map.setCenter(initLoc);
}

function template(selector) {
  if (undefined === window.templates) {
    window.templates = {};
  }
  
  if (undefined === window.templates[selector]) {
    var item = $(selector + '.template').detach();
    item.removeClass('template');
    window.templates[selector] = item;
  }

  return window.templates[selector].clone();
}

