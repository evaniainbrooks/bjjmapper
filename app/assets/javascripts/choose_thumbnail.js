+function() {
  var WIDTH_HEIGHT = 100;

  function storeThumbnailPosition(x, y) {
    $("[name='user[thumbnailx]']").val(x);
    $("[name='user[thumbnaily]']").val(y);
  };

  function setThumbnailVisibility(visibility) {
    $('.thumbnail-overlay').css('visibility', visibility);
  };

  function positionThumbnail(x, y) {
    var container = $('.edit-image-container');
    var image = container.find('.edit-image');

    var leftMargin = Math.ceil((container.width() - image.width()) / 2);

    if (x < 0) x = 0;
    if (y < 0) y = 0;

    if (x + WIDTH_HEIGHT > image.width()) x = image.width() - WIDTH_HEIGHT;
    if (y + WIDTH_HEIGHT > image.height()) y = image.height() - WIDTH_HEIGHT;

    $('.thumbnail-overlay').css({
      top: y,
      left: x + leftMargin
    });

    return { x: x, y: y };
  };

  function positionThumbnailFromStore() {
    var x = parseInt($("[name='user[thumbnailx]']").val(), 10);
    var y = parseInt($("[name='user[thumbnaily]']").val(), 10);

    positionThumbnail(x, y);
    setThumbnailVisibility('visible');
  };

  $(document).ready(function() {
    positionThumbnailFromStore();

    $('body').delegate('.edit-image-container', 'click', function(e) {
      var offset = $('.edit-image').offset();
      var x = e.pageX - offset.left - WIDTH_HEIGHT / 2;
      var y = e.pageY - offset.top - WIDTH_HEIGHT / 2;

      var position = positionThumbnail(x, y);
      storeThumbnailPosition(position.x, position.y);
    });
  });

  RollFindr.GlobalEvents.on('editing', function(editing) {
    positionThumbnailFromStore();
  });
}();
