#= require templates/user-review
#= require backbone/models/review

class RollFindr.Views.UserReviewsView extends Backbone.View
  model: null
  el: $('.reviews')
  template: JST['templates/user-review']
  initialize: (options)->
    _.bindAll(this, 'render')
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

