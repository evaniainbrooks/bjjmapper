$(document).ready(function() {
  var WIDTH_HEIGHT = 100;

  var container = $('.edit-image-container');
  var offset = container.offset();
  var image = container.find('.edit-image');

  var leftMargin = Math.ceil((container.width() - image.width()) / 2);

  var x = parseInt($("[name='user[thumbnailx]']").val(), 10) + leftMargin;
  var y = parseInt($("[name='user[thumbnaily]']").val(), 10);

  $('.thumbnail-overlay').css('top', y).css('left', x).css('visibility', 'visible');
  $('body').delegate('.edit-image-container', 'click', function(e) {
    container = $(this);
    offset = container.offset();
    image = container.find('.edit-image');
    leftMargin = Math.ceil((container.width() - image.width()) / 2);

    x = (e.pageX - offset.left) - leftMargin - WIDTH_HEIGHT / 2;
    y = (e.pageY - offset.top) - WIDTH_HEIGHT / 2;

    if (x < 0) x = 0;
    if (y < 0) y = 0;

    if (x + WIDTH_HEIGHT > image.width()) x = image.width() - WIDTH_HEIGHT;
    if (y + WIDTH_HEIGHT > image.height()) y = image.height() - WIDTH_HEIGHT;

    var form = $(e.currentTarget).parents('form');

    form.find("[name='user[thumbnailx]']").val(x);
    form.find("[name='user[thumbnaily]']").val(y);

    form.find('.thumbnail-overlay').css('top', y).css('left', x + leftMargin);
  });
});
