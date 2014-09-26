//= require confirm-dialog

+function($, _) {
  
  $('body').delegate('[data-delete-item]', 'click', function(e) {
    var data = $(e.target).data();
    var deleteDefaults = {
      method: 'DELETE',
      type: 'danger'
    };

    var options = $.extend({}, deleteDefaults, data);
    RollFindr.ConfirmDialog(options);
  });

}(jQuery, _);
