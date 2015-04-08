//= require confirm_dialog

+function($, _) {
  $('body').delegate('[data-method="delete"]', 'click', function(e) {
    var data = $(e.target).data();
    var deleteDefaults = {
      method: 'DELETE',
      type: 'danger'
    };

    var options = $.extend({}, deleteDefaults, data);
    RollFindr.ConfirmDialog(options);

    e.preventDefault();
    return false;
  });

}(jQuery, _);
