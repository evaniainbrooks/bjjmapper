class RollFindr.Models.Review extends Backbone.Model
  paramRoot: 'review'
  urlRoot: ->
    Routes.location_review_path(@location, @id)
  defaults:
    body: null
    rating: null

class RollFindr.Collections.ReviewsCollection extends Backbone.Collection
  model: RollFindr.Models.Review
  location_id: null
  initialize: (models, options)->
    _.extend(this, _.pick(options, "user_id", "location_id"))

  url: =>
    if @location_id?
      Routes.location_reviews_path(@location_id)
    else
      Routes.reviews_user_path(@user_id)
