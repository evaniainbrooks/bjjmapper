+function(_,$) {
  $(document).ready(function() {
    $('html').delegate('.editable [data-cancel-edit]', 'click', function(e) {
      $(e.target).parents('.editable').removeClass('edit-mode');
      RollFindr.GlobalEvents.trigger('editing', false);
      e.preventDefault();
    });
    $('html').delegate('.editable [data-begin-edit]', 'click', function(e) {
      if (!RollFindr.CurrentUser.isAnonymous()) {
        $(e.target).parents('.editable').addClass('edit-mode');
        RollFindr.GlobalEvents.trigger('editing', true);
      } else {
        $('.login-modal').modal('show');
      }

      if (!$(e.currentTarget).data('follow-href')) {
        e.preventDefault();
        return false;
      } else {
        return true;
      }
    });
  });
}(_,jQuery);
