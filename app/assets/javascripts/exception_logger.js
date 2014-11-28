//= require mixpanel

window.onerror = function(errorMessage, url, lineNumber) {
  "use strict";
  mixpanel.track("errorJavaScriptException", {
    error_message: errorMessage,
    url: url,
    line_number: lineNumber
  });

  return false;
};

