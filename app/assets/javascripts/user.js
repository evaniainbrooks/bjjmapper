+function() {
  "use strict";

  window.userIsAuthenticated = function() {
    return undefined !== $('body').data('userid');
  };

}();
