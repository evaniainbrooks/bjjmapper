+function($) {

  var colours = ["#1abc9c", "#2ecc71", "#3498db", "#9b59b6", "#34495e", "#16a085", "#27ae60", "#2980b9", "#8e44ad", "#2c3e50", "#f1c40f", "#e67e22", "#e74c3c", "#95a5a6", "#f39c12", "#d35400", "#c0392b", "#bdc3c7"];

  var generateAvatars = function(elems) {  
    if (typeof elems == "undefined") elems = $('[data-avatar-placeholder]');

    _.each(elems, function(e) {
      var name = $(e).data('name');  
      var nameSplit = name.split(" ");
      var initials = nameSplit[0].charAt(0).toUpperCase() + nameSplit[nameSplit.length - 1].charAt(0).toUpperCase();

      var charIndex = initials.charCodeAt(0) - 65,
          colourIndex = charIndex % 19;

      var canvas = $(e)[0]; 
      var context = canvas.getContext("2d");

      var canvasWidth = $(canvas).attr("width"),
          canvasHeight = $(canvas).attr("height"),
          canvasCssWidth = canvasWidth,
          canvasCssHeight = canvasHeight;

      /*if (window.devicePixelRatio) {
          $(canvas).attr("width", canvasWidth * window.devicePixelRatio);
          $(canvas).attr("height", canvasHeight * window.devicePixelRatio);
          $(canvas).css("width", canvasCssWidth);
          $(canvas).css("height", canvasCssHeight);
          context.scale(window.devicePixelRatio, window.devicePixelRatio);
      }*/

      context.fillStyle = colours[colourIndex]; 
      context.fillRect (0, 0, canvasWidth, canvasHeight);
      context.font = ((canvasWidth / 3) + 10) + "px Arial";
      context.textAlign = "center";
      context.fillStyle = "#FFF";
      context.fillText(initials, canvasWidth / 2, canvasHeight / 1.5);
    });
  }

  $(document).ready(function() {
    generateAvatars();  
  });

  window.generateAvatars = generateAvatars;

}(jQuery);
