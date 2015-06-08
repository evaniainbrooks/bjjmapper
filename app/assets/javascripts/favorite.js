+function($) {
  var set_favorite = function(e, remove) {
    var id = $(e.currentTarget).data('id');
    var p = $(e.currentTarget).parent('.favorite');
    $.ajax({
      url: Routes.favorite_location_path(id),
      method: 'POST',
      data: {
        format: 'json',
        'delete': remove
      },
      beforeSend: function() {
        p.toggleClass('saved');
      },
      error: function() {
        p.toggleClass('saved');
      }
    });
  };

  $(document).ready(function() {
    $('html').delegate('.save-favorite', 'click', function(e) {
      set_favorite(e, 0);
    });
    $('html').delegate('.clear-favorite', 'click', function(e) {
      set_favorite(e, 1);
    });
  });
}(jQuery);
