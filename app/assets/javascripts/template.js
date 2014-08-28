function template(selector) {
  if (undefined === window.templates) {
    window.templates = {};
  }
  
  if (undefined === window.templates[selector]) {
    var item = $(selector + '.template').detach();
    item.removeClass('template');
    window.templates[selector] = item;
  }

  return window.templates[selector].clone();
}
