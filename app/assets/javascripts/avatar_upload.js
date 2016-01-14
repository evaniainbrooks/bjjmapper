+function() {

  var timeoutId = undefined;
  var fetchTryCount = 0;

  var FETCH_TRY_LIMIT = 5;

  function fetchUpdatedImage() {
    var userUrl = $('form').attr('action');
    $.ajax({
      url: userUrl,
      type: 'GET',
      dataType: 'json',
      success: function(userData) {
        if (userData.image !== $('img.profile').attr('src')) {
          $('img.profile').attr('src', userData.image);
        } else if (++fetchTryCount < FETCH_TRY_LIMIT) {
          checkForUpdatedImage();
        }
      }
    });
  };

  function checkForUpdatedImage() {
    timeoutId = window.setTimeout(fetchUpdatedImage, 5000);
  };

  $(document).ready(function() {
    $('html').delegate('[data-clear-avatar]', 'click', function(e) {
      var url = $(e.currentTarget).data('url');
      $.ajax({
        url: url,
        type: 'POST',
        dataType: 'json',
        success: function() {
          toastr.success('Image processing may take a few minutes. Please check back soon.', 'Image successfully removed');
        },
        error: function() {
          toastr.error('Please try again later. If you believe this to be a bug, please email us at info@bjjmapper.com', 'Image removal failed');
        }
      })
    });

    $('html').delegate('[data-upload-avatar]', 'change', function(e) {
      var files = e.currentTarget.files;
      var url = $(e.currentTarget).data('url');

      var data = new FormData();
      data.append('file', files[0]);

      $.ajax({
        url:  url,
        type: 'POST',
        cache: false,
        dataType: 'html',
        processData: false,
        contentType: false,
        data: data,
        success: function() {
          checkForUpdatedImage();
          toastr.success('Image processing may take a few minutes. Please check back soon.', 'Image successfully uploaded');
        },
        error: function() {
          toastr.error('Please try again later. If you believe this to be a bug, please email us at info@bjjmapper.com', 'Image upload failed');
        }
      });

      e.preventDefault();
      return false;
    });
  });
}();
