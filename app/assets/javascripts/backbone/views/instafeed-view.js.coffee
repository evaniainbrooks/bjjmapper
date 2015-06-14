class RollFindr.Views.InstaFeedView extends Backbone.View
  el: $('.instafeed')
  feed: null
  events:
    'click .load-more' : 'loadClicked'

  initialize: (options)->
    _.bindAll(this, 'loadClicked', 'render', 'afterLoadCallback')
    _.extend(this, _.pick(options, 'hashtag', 'client_id'))

    @feed = new Instafeed(
      tagName: @hashtag
      clientId: @client_id
      limit: 16
      get: 'tagged'
      sortBy: 'most-recent'
      after: @afterLoadCallback
    )

    @render()

  render: ->
    @feed.run()

  loadClicked: ->
    @$('.load-more').attr('disabled', true)
    @feed.next()

  afterLoadCallback: ->
    if !@feed.hasNext()
      @$('.load-more').attr('disabled', true)
    else
      @$('.load-more').attr('disabled', false)
      @$('.load-more').css('display', 'inline-block')

