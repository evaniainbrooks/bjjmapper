+function(jQuery) {
  $(document).delegate('.navbar-collapse.in', 'click', function(e) {
    if( ($(e.target).is('a') || $(e.target).is('button')) && $(e.target).attr('class') != 'dropdown-toggle' ) {
        $(this).collapse('hide');
    }
  });
}($);