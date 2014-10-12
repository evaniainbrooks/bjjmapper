//= require application
//= require sinon
//= require chai-changes
//= require js-factories
//= require chai-backbone
//= require chai-jquery

chai.config.includeStack = true;

$.fn.addHtml = function(element_type, opt) {
  var elem = $(document.createElement(element_type));
  elem.attr(opt).html('testText').appendTo($(this));
  return elem;
}

window.stubGoogleMapsApi = function() {
  return window.google = {
    maps: {
      event: {
        addListener: function() {}
      },
      LatLng: function() {
        return {}; 
      },
      LatLngBounds: function() {
        return {
          contains: function(){}
        };
      },
      MapTypeId: {
        SATELLITE: '',
        HYBRID: ''
      },
      Map: function() {
        return {
          getBounds: function(){},
          setCenter: function(){},
          setTilt: function(){},
          mapTypes: {
            set: function() {}
          },
          overlayMapTypes: {
            insertAt: function() {},
            removeAt: function() {}
          }
        };
      },
      Marker: function() {},
      MaxZoomService: function() {
        return {
          getMaxZoomAtLatLng: function() {}
        };
      },
      ImageMapType: function() {},
      Size: function() {},
      Point: function() {},
      places: {
        AutocompleteService: function() {
          return {
            getPlacePredictions: function() {}
          };
        }
      }
    }
  };
};
