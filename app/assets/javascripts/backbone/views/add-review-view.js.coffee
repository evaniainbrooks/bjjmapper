class RollFindr.Views.AddReviewView extends Backbone.View
  el: $('.add-review-dialog')
  events: {
    'click [data-rating]' : 'setRating'
  }
  initialize: ->
    _.bindAll(this, 'setRating')
  setRating: (e)->
    enabledClasses = 'fa-star fa fa-3x'
    disabledClasses = 'fa-star-o fa fa-3x'

    star = $(e.currentTarget)

    @$('[name="review[rating]"]').val(star.data('rating'))
    @$('[name="review[body]"]').removeAttr('disabled')
    @$('[name="review[body]"]').focus()
    @$('[type="submit"]').removeAttr('disabled')

    star.attr('class', enabledClasses)
    star.prevAll().attr('class', enabledClasses)
    $(e.currentTarget).nextAll().attr('class', disabledClasses)
