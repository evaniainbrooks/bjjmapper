//= require jquery
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
      ControlPosition: {
        TOP_LEFT: 0
      },
      event: {
        addListener: function() {},
        addListenerOnce: function() {}
      },
      InfoWindow: function() {

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
          controls: [{ push: function() {} }],
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

// Stub CurrentUser
window.stubCurrentUser = function() {
  RollFindr.CurrentUser = new RollFindr.Models.User();
  RollFindr.CurrentUser.set('role', 'super_user');
};

window.stubAnonymousUser = function() {
  RollFindr.CurrentUser = new RollFindr.Models.User();
  RollFindr.CurrentUser.set('role', 'anonymous');
};

window.stubGoogleMapsApi();

