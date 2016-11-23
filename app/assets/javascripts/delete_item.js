//= require confirm_dialog

+function($, _) {
  var confirm_dialog = function(e, method, type) {
    var data = $(e.target).data();
    var deleteDefaults = {
      method: method,
      type: type,
      url: $(e.target).attr('href')
    };

    var options = $.extend({}, deleteDefaults, data);
    RollFindr.ConfirmDialog(options);

    e.preventDefault();
    return false;
  };
  
  $('body').delegate('[data-method="delete"]', 'click', function(e) {
    return confirm_dialog(e, 'DELETE', 'danger');
  });
  
  $('body').delegate('[data-method="post"]', 'click', function(e) {
    return confirm_dialog(e, 'POST', 'primary');
  });
  
  $('body').delegate('[data-method="put"]', 'click', function(e) {
    return confirm_dialog(e, 'PUT', 'primary');
  });

}(jQuery, _);
