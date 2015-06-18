//= require backbone/rollfindr

+function() {

  window.RollFindr.AvatarService = function(name) {
    var cleanName = name.replace(/[/&?]/g, ' ');
    return "/service/avatar/100x100/" + encodeURI(cleanName) + "/image.png";
  };

}();

