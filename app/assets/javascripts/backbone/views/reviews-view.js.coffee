#= require templates/review
#= require backbone/models/review

class RollFindr.Views.ReviewsView extends Backbone.View
  model: null
  el: $('.reviews')
  template: null
  initialize: (options)->
    _.bindAll(this, 'render')
    @template = JST["templates/#{options.template_name}"]
    @model.get('reviews').fetch({
      beforeSend: =>
        @$el.addClass('loading')
      complete: =>
        @$el.removeClass('loading')
    }).done(@render)

  render: ->
    @$('.items').empty()
    if @model.get('reviews').size() > 0
      @$el.removeClass('empty')
      @model.get('reviews').each (review)=>
        elem = @template({review: review.toJSON()})
        @$('.items').append(elem)
    else
      @$el.addClass('empty')

