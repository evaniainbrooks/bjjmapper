//= require application
//= require sinon
//= require chai-changes
//= require js-factories
//= require chai-backbone
//= require chai-jquery

chai.config.includeStack = true;

$.fn.addHtml = function(element_type, opt) {
  var elem = $(document.createElement(element_type));
  elem.attr(opt).html('testText').appendTo($(this));
  return elem;
}

