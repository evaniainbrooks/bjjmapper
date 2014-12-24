#= require templates/review
#= require backbone/models/review

class RollFindr.Views.LocationReviewsView extends Backbone.View
  model: null
  el: $('.reviews')
  template: JST['templates/review']
  initialize: ->
    _.bindAll(this, 'render')
    @model.get('reviews').fetch().done(@render)

  render: ->
    @$('.items').empty()
    if @model.get('reviews').size() > 0
      @$el.removeClass('empty')
      @model.get('reviews').each (review)=>
        elem = @template({review: review.toJSON()})
        @$('.items').append(elem)
    else
      @$el.addClass('empty')

