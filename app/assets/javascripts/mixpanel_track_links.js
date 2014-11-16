+function($) {
  "use strict";

  setTimeout(function() {
    if ("undefined" !== window.mixpanel) {
      mixpanel.register({
        "user_id": $('body').data('userid'),
        "url": window.location
      });

      mixpanel.track_links('a.phone', 'linkPhoneClick', function(element) {
        return { 'href':  $(element).attr('href') };
      });

      mixpanel.track_links('a.email', 'linkEmailClick', function(element) {
        return { 'href':  $(element).attr('href') };
      });

      mixpanel.track_links('a.website', 'linkWebsiteClick', function(element) {
        return { 'href':  $(element).attr('href') };
      });
    }
  }, 500);
}(jQuery);
