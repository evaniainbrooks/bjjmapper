+function($, _) {
  
  var template = _.template( $('.confirm-dialog-template').html() ); 
    
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
  
  $('body').delegate('[data-delete-item]', 'click', function(e) {
    var target = $(e.target);  
    var data = target.data();
    var defaults = {
      title: 'Are you sure?',
      type: 'primary',
      confirm: 'Confirm',
      cancel: 'Cancel',
      method: 'DELETE'
    };

    var templateArgs = $.extend({}, defaults, data);
    console.log(templateArgs);
    var dialog = template(templateArgs);
    
    $('body').append(dialog);
    $(dialog).modal('show');
  });

}(jQuery, _);
