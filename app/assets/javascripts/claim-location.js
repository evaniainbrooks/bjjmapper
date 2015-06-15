+function($) {

  $('html').delegate('[data-claim-location]', 'click', function(e) {
    $('.claim-location-dialog').modal('show');
    e.preventDefault();
  });

}(jQuery);

