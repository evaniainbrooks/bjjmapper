//= require backbone/rollfindr

+function() {

  window.RollFindr.AvatarService = function(name) {
    return "/service/avatar/100x100/" + encodeURI(name) + "/image.png";
  }

}();

