class RollFindr.Views.NavbarView extends Backbone.View
  el: $('.navbar')
  tagName: 'div'
  initialize: ->
    globalSearch = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('title'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      identify: (o)->
        o.title
      , 
      remote: {
        url: Routes.search_path({ format: 'json', q: 'QQQUERY' }),
        wildcard: 'QQQUERY'
      }
    })
    
    findResultSet = (entity, results)->
      resultSet = _.find results, (e)->
        e.name == entity

      return [] unless resultSet?
      return resultSet.results
    
    callbacks = {}
    invoker = (results)->
      for own key of callbacks
        callbacks[key](findResultSet(key, results))

    adapter = _.debounce(globalSearch.ttAdapter(), 10)
    searchFn = (entity, q, sync, async)->
      callbacks[entity] = async
      adapter(q, _.identity, invoker)

    options = { minLength: 3, highlight: true }
    el = @$("[name='query']").typeahead options,
      {
        name: 'locations',
        display: 'title',
        source: _.partial(searchFn, 'location') 
        templates: {
          suggestion: (o)-> 
            div = document.createElement("div")
            div.appendChild(document.createTextNode(o.title))
            div

          header: '<small class="tt-suggestion-header"><span class="fa fa-dot-circle-o"></span> Academies</small>'
        }
      },
      {
        name: 'addresses',
        display: 'address',
        source: _.partial(searchFn, 'address') 
        templates: {
          suggestion: (o)-> 
            div = document.createElement("div")
            div.appendChild(document.createTextNode(o.address))
            div
          header: '<small class="tt-suggestion-header"><span class="fa fa-map-marker"></span> Addresses</small>'
        }
      },
      {
        name: 'users',
        display: 'name',
        source: _.partial(searchFn, 'user') 
        templates: {
          suggestion: (o)-> 
            div = document.createElement("div")
            div.appendChild(document.createTextNode(o.name))
            div
          header: '<small class="tt-suggestion-header"><span class="fa fa-user"></span> People</small>'
        }
      },
      {
        name: 'teams',
        display: 'name',
        source: _.partial(searchFn, 'team') 
        templates: {
          suggestion: (o)-> 
            div = document.createElement("div")
            div.appendChild(document.createTextNode(o.name))
            div
          header: '<small class="tt-suggestion-header"><span class="fa fa-group"></span> Teams</small>'
        }
      }
    
    el.bind 'typeahead:selected', (e, datum, name)->
      window.location = datum.url


