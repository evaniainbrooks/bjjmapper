+function($, _) {
  var template = _.template( $('.confirm-dialog-template').html() ); 
  $('body').delegate('[data-delete-item]', 'click', function(e) {
    var target = $(e.target);  
    var title = target.data('title');
    var body = target.data('body');
    var confirmMessage = target.data('confirm');
    var cancelMessage = target.data('cancel');
    var action = target.data('delete-item');
    var dialog = template({
      title: title || 'Are you sure?',
      body: body,
      confirm: confirmMessage || 'Confirm',
      cancel: cancelMessage || 'Cancel'
    });

    $('body').append(dialog);
    $(dialog).modal('show');
  });

}(jQuery, _);
