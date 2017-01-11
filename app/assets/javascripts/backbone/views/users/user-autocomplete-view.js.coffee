#= require backbone/models/user
#= require user-autocomplete

class RollFindr.Views.UserAutocompleteView extends Backbone.View
  model: null
  el: $('.typeahead')
  target: $('[name="id"]')
  template: JST['templates/locations/instructor']
  initialize: (options)->
    _.bindAll(this, 'userSelected')
  
    options = { minLength: 3 };
    @$el.typeahead(options, {
      name: 'user-names',
      display: 'name',
      source: window.UserNamesAutocomplete
    })
  
    @$el.bind 'typeahead:selected', @userSelected 

  userSelected: (e, datum, name)->
    @target.val(datum.id)

