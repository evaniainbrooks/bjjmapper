//= require js-routes
//= require typeahead.bundle.min

+function() {
  var userNames = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    identify: function(o) {
      return o.name;
    },
    sufficient: 2,
    prefetch: Routes.users_path({ format: 'json', rank: 'black' }),
    remote: {
      url: Routes.users_path({ format: 'json', query: 'QQQUERY' }),
      wildcard: 'QQQUERY'
    }
  });

  window.UserNamesAutocomplete = userNames;
}();
