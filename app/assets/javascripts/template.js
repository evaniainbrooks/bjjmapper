+function() {
  if (typeof window.Template === "undefined") {
    window.Template = {
      templates: {},
      callbacks: {}
    };
  }

  window.Template.create = function(selector, data) {
    if (undefined === window.Template.templates[selector]) {
      var item = $('.' + selector + '.template').detach();
      item.removeClass('template');
      window.Template.templates[selector] = {
        item: item
      };
    
      var onCreate = item.data('oncreate');
      if ("undefined" !== typeof onCreate) {
        window.Template.templates[selector].onCreate = onCreate;
      }
    }

    var templateCopy = window.Template.templates[selector].item.clone();
    if ("undefined" !== typeof window.Template.templates[selector].onCreate) {
      var name = window.Template.templates[selector].onCreate;
      window.Template.callbacks[name](templateCopy, data);
    }
    return templateCopy;
  }
}();
