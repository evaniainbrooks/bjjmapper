+function($) {
  "use strict";
  $('body').delegate('[data-report-item]', 'click', function(e) {
    $('.report-dialog').modal('show');
    e.preventDefault();
  });

}(jQuery);

