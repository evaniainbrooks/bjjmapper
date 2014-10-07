+function($,_) {
  "use strict";

  var template = JST['templates/confirm_dialog']; 
  $('body').delegate('.confirm-dialog button.confirm', 'click', function(e) {
    var method = $(e.target).data('method');
    var url = $(e.target).data('url');
    $.ajax({
      type: 'POST',
      data: { '_method': method.toLowerCase() },
      dataType: 'json',
      url: url,
      success: function(response, status, xhr) {  
        $(e.target).parents('.confirm-dialog').modal('hide');
        window.location = Routes.root_path();
      }
    });
  });

  RollFindr.ConfirmDialog = function(data) {
    var defaults = {
      title: 'Are you sure?',
      type: 'primary',
      confirm: 'Confirm',
      cancel: 'Cancel',
      method: 'POST' 
    };
    
    var templateArgs = $.extend({}, defaults, data);
    var dialog = template(templateArgs);
    
    $('body').append(dialog);
    $(dialog).modal('show');
  };
}(jQuery, _);
