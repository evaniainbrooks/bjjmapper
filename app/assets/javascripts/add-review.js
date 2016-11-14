+function($) {
  $('html').delegate('.add-review', 'click', function(e) {
    var locid = $(e.currentTarget).data('location-id');
    var url = Routes.location_reviews_path(locid);
    $('.add-review-dialog form').attr('action', url);
    $('.add-review-dialog').modal('show');
  });
}(jQuery);
