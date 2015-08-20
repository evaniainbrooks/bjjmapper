+function($) {
  $(document).ready(function() {
    $('form').submit(function() {
      var btn = $(this).find("button[type='submit']:not([data-nodisable])");
      btn.prop('disabled',true);
    });
  });
}(jQuery);
