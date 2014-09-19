+function() {
  "use strict";
  Template.registerTemplateCallback('show-location', function(elements, data) {
    $.each(elements, function(i, o) {
      $('.title', o).text(data.title);
      $('.team-name', o).text(data.team_name);
      $('.description', o).text(data.description);
      //$('.coords', o).text(data.coordinates);
      $('a.more', o).attr('href', Routes.location_path(data.id));
      $('.updated-at', o).text(data.updated_at)
      $('.address', o).text(data.address);
    });
  });
}();
