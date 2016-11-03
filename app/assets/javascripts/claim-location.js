+function($) {

  $('html').delegate('[data-claim-location]', 'click', function(e) {
    $('.claim-location-dialog').modal('show');
    e.preventDefault();
  });

  $('html').delegate('[data-close-location]', 'click', function(e) {
    var location_id = $(e.currentTarget).data('id');
    $.ajax({
      url: Routes.close_location_path(location_id),
      method: 'POST',
      data: { 
        format: 'json',
        closed: true
      },
      success: function() {
        window.location = Routes.location_path(location_id);
      }
    });
    e.preventDefault();
  });

}(jQuery);

