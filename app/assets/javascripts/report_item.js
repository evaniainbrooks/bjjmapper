+function($) {
  "use strict";
  $('html').delegate('[data-report-item]', 'click', function(e) {
    $('.report-dialog').modal('show');
    e.preventDefault();
  });

}(jQuery);

