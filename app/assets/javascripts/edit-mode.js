+function(_,$) {
  $(document).ready(function() {
    $('html').delegate('.editable [data-cancel-edit]', 'click', function(e) {
      $(e.target).parents('.editable').removeClass('edit-mode');
      e.preventDefault();
    });
    $('html').delegate('.editable [data-begin-edit]', 'click', function(e) {
      $(e.target).parents('.editable').addClass('edit-mode');
      e.preventDefault();
    });
  });
}(_,jQuery);
