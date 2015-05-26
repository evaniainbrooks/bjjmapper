+function(jQuery) {
  function confirmPageExitHandler(e) {
      // If we haven't been passed the event get the window.event
      e = e || window.event;
      var message = 'All of your changes will be lost.';

      // For IE6-8 and Firefox prior to version 4
      if (e) {
          e.returnValue = message;
      }

      // For Chrome, Safari, IE8+ and Opera 12+
      return message;
  };

  window.enableConfirmPageExit = function() {
    window.onbeforeunload = confirmPageExitHandler;
  };

  window.disableConfirmPageExit = function() {
    window.onbeforeunload = null;
  };

  $(document).ready(function() {
    $('button[type="submit"]').click(function(e) {
      disableConfirmPageExit();
    });
  });

}($);

