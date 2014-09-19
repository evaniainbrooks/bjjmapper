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
      window.Template.templates[selector] = item;
    }

    var templateCopy = window.Template.templates[selector].clone();
    if ("undefined" !== typeof window.Template.callbacks[selector]) {
      window.Template.callbacks[selector](templateCopy, data);
    }
    return templateCopy;
  };

  window.Template.registerTemplateCallback = function(selector, callback) {
    window.Template.callbacks[selector] = callback;
  }
}();
