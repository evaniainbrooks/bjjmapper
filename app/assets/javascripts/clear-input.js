+function($) {
  $('.clear-input').keyup(function () {
    var t = $(this);
    t.next('.clear-input-button').toggle(Boolean(t.val()));
  });
  $('.clear-input-button').hide($(this).prev('input').val());
  $('.clear-input-button').click(function (e) {
    $(this).prev('input').val('').focus();
    $(this).hide();
    $(this).parents('form').submit();
    e.preventDefault();
    return false;
  });
}(jQuery);
