chai.config.includeStack = true;

ENV = {
    TESTING: true
};

beforeEach(function() {
  window.SANDBOX = $("#konacha");
  $.fn.addHtml = function(element_type, opt) {
    var elem = $(document.createElement(element_type));
    elem.attr(opt).html('testText').appendTo($(this));
    return elem;
  };
});

var noop = function() {};

var stubGoogleMapsApi = function() {
  return window.google = {
    maps: {
      ControlPosition: {
        TOP_LEFT: 0
      },
      DirectionsRenderer: noop,
      DirectionsService: noop,
      event: {
        addListener: noop,
        addListenerOnce: noop,
      },
      InfoWindow: noop,
      LatLng: function() {
        return {};
      },
      LatLngBounds: function() {
        return {
          contains: noop
        };
      },
      MapTypeId: {
        SATELLITE: '',
        HYBRID: ''
      },
      Map: function() {
        return {
          controls: [{ push: noop }],
          getBounds: noop,
          setCenter: noop,
          setTilt: noop,
          mapTypes: {
            set: noop
          },
          overlayMapTypes: {
            insertAt: noop,
            removeAt: noop
          }
        };
      },
      Marker: noop,
      MaxZoomService: function() {
        return {
          getMaxZoomAtLatLng: noop
        };
      },
      ImageMapType: noop,
      Size: noop,
      Point: noop,
      places: {
        AutocompleteService: function() {
          return {
            getPlacePredictions: noop
          };
        }
      }
    }
  };
};

// Stub CurrentUser
window.stubCurrentUser = function() {
  RollFindr.CurrentUser = new RollFindr.Models.User();
  RollFindr.CurrentUser.set('id', '12345');
  RollFindr.CurrentUser.set('is_anonymous', false);
};

window.stubAnonymousUser = function() {
  RollFindr.CurrentUser = new RollFindr.Models.User();
  RollFindr.CurrentUser.set('is_anonymous', true);
};

stubGoogleMapsApi();

