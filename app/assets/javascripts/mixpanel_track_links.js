//= require user_helper

+function($) {
  "use strict";

  $(document).ready(function() {
      mixpanel.register({
        "user_id": currentUserId(),
        "logged_in": isLoggedIn(),
        "url": window.location.href
      });

      mixpanel.track_links('a.phone', 'clickPhoneLink', function(element) {
        return { 'href':  $(element).attr('href') };
      });
      mixpanel.track_links('a.email', 'clickEmailLink', function(element) {
        return { 'href':  $(element).attr('href') };
      });
      mixpanel.track_links('a.website', 'clickWebsiteLink', function(element) {
        return { 'href':  $(element).attr('href') };
      });
      mixpanel.track_links('a.facebook', 'clickFacebookLink', function(element) {
        return { 'href':  $(element).attr('href') };
      });


      mixpanel.track_links('a.facebook-login-btn', 'clickRegisterExternal', function(element) {
        return { 'href':  $(element).attr('href'), 'service': 'facebook' };
      });
      mixpanel.track_links('a.google-login-btn', 'clickRegisterExternal', function(element) {
        return { 'href':  $(element).attr('href'), 'service': 'google' };
      });
      mixpanel.track_links('a.twitter-login-btn', 'clickRegisterExternal', function(element) {
        return { 'href':  $(element).attr('href'), 'service': 'twitter' };
      });
  });
}(jQuery);
