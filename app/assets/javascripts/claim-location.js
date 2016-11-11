+function($) {

  $('html').delegate('[data-claim-location]', 'click', function(e) {
    $('.claim-location-dialog').modal('show');
    e.preventDefault();
  });
  
  var closeLocation = function(e) {
    var location_id = $(e.currentTarget).data('id');
    var reopen = $(e.currentTarget).is('[data-reopen-location]') ? 1 : 0;

    $.ajax({
      url: Routes.close_location_path(location_id),
      method: 'POST',
      data: { 
        format: 'json',
        reopen: reopen
      },
      success: function() {
        window.location = Routes.location_path(location_id);
      }
    });
  };

  $('html').delegate('[data-close-location]', 'click', closeLocation); 
  $('html').delegate('[data-reopen-location]', 'click', closeLocation); 

}(jQuery);

