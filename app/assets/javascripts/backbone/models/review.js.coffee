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
    if options?
      _.extend(this, _.pick(options, "user_id", "location_id"))

  url: =>
    if @location_id?
      Routes.location_reviews_path(@location_id)
    else
      Routes.user_reviews_path(@user_id)

class RollFindr.Models.ReviewsResponse extends Backbone.Model
  urlRoot: =>
    Routes.location_reviews_path(@location_id)

  initialize: (options)->
    @location_id = options.location_id

    reviews = @get('reviews')
    reviews = new RollFindr.Collections.ReviewsCollection(reviews, {location_id: @location_id})
    @set('reviews', reviews)
    @listenTo(this, 'change:reviews', this.onChangeReviews)

  onChangeReviews: =>
    reviews = @get('reviews')
    if Object.prototype.toString.call(reviews) == '[object Array]'
      @set('reviews', new RollFindr.Collections.ReviewsCollection(reviews), {silent: true})
