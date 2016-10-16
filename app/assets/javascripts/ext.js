+function() {
  if (typeof(Number.prototype.toRad) === "undefined") {
    Number.prototype.toRad = function() {
      return this * Math.PI / 180;
    }
  }

  if (typeof(String.prototype.pluralize) === "undefined") {
    String.prototype.pluralize = function(count) {
      if (count === 1) {
        return count.toString() + ' ' + this;
      } else {
        return count.toString() + ' ' + this + 's';
      }
    }
  }
}();
