+function(_,$) {

  $('body').delegate('.editable button[data-cancel-edit]', 'click', function(e) {
    $(e.target).parents('.editable').removeClass('edit-mode');
  });

}(_,jQuery);
