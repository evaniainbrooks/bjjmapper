+function(_,$) {
  $(document).ready(function() {
    var set_lineal_parent = function(student, teacher) {
      var url = Routes.user_path(student);
      var data = {
        format: 'json',
        _method: 'patch',
        user: {
          lineal_parent_id: teacher
        }
      };

      $.ajax({
        method: 'POST',
        url: url,
        data: data,
        success: function(response) {
          window.location.reload();
        },
        error: function() {
          toastr.error('Please try again later. If you believe this to be a bug, please email us at info@bjjmapper.com', 'Failed to modify lineage!');
        }
      })
    };

    $('html').delegate('[data-claim-instructor]', 'click', function(e) {
      var target = $(e.currentTarget);
      var teacher = target.data('user-id');
      set_lineal_parent(currentUserId(), teacher);
    });
    $('html').delegate('[data-claim-student]', 'click', function(e) {
      var target = $(e.currentTarget);
      var student = target.data('user-id');
      set_lineal_parent(student, currentUserId());
    });
    $('html').delegate('[data-clear-instructor]', 'click', function(e) {
      var target = $(e.currentTarget);
      var teacher = target.data('user-id');
      set_lineal_parent(currentUserId(), null);
    });

    $('html').delegate('[data-clear-student]', 'click', function(e) {
      var target = $(e.currentTarget);
      var student = target.data('user-id');
      set_lineal_parent(student, null);
    });
  });
}(_, jQuery);

