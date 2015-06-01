+function($) {
  $(document).ready(function() {
    $('form').submit(function() {
      $(this).find("button[type='submit']").prop('disabled',true);
    });
  });
}(jQuery);
