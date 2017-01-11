#= require templates/review
#= require templates/rating-stars
#= require backbone/models/review

class RollFindr.Views.LocationReviewsView extends Backbone.View
  model: null
  el: $('.reviews')
  ratingTemplate: JST["templates/rating-stars"]
  reviewTemplate: JST["templates/review"]
  initialize: (options)->
    @model = new RollFindr.Models.ReviewsResponse(location_id: options.location_id)
    _.bindAll(this, 'render')
    @model.fetch({
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
        elem = @reviewTemplate({review: review.toJSON()})
        @$('.items').append(elem)
    else
      @$el.addClass('empty')

    $('.rating-container').html(@ratingTemplate(location: @model.toJSON()))

