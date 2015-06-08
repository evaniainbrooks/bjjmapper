+function($,_) {
  "use strict";

  var template = JST['templates/confirm_dialog']; 
  $('html').delegate('.confirm-dialog button.confirm', 'click', function(e) {
    var method = $(e.target).data('method') || 'POST';
    var url = $(e.target).data('url');
    var returnTo = $(e.target).data('returnto');
    var extraData = {};
    extraData['_method'] = method.toLowerCase();

    $.ajax({
      type: method,
      data: extraData,
      dataType: 'json',
      url: url,
      success: function(response, status, xhr) {  
        $(e.target).parents('.confirm-dialog').modal('hide');
        window.location = returnTo;
      },
      error: function() {
        toastr.error('Please try again later. If you believe this to be a bug, email us at info@bjjmapper.com', 'An error has occurred');
      }
    });
  });

  RollFindr.ConfirmDialog = function(data) {
    var defaults = {
      title: 'Are you sure?',
      type: 'primary',
      confirm: 'Confirm',
      cancel: 'Cancel',
      method: 'POST',
      returnto: Routes.root_path()
    };

    var templateArgs = $.extend({}, defaults, data);
    var dialog = template(templateArgs);


    $('.confirm-dialog').remove();
    $(dialog).modal('show');
  };
}(jQuery, _);
