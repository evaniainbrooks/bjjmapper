#= require spec_helper
#= require backbone/rollfindr
#= require instafeed.min

describe 'Views.InstaFeedView', ->
  testClientId = 'client1234'
  testTag = 'carlsongracie'

  subject = null
  feedSpy = null

  createDom = ->
    f = $('body').html('').addHtml('div', class: 'instafeed')
    f.addHtml('button', class: 'load-more')
    f.addHtml('div', id: 'instafeed')

  createSubject = ->
    subject = new RollFindr.Views.InstaFeedView(el: $('.instafeed'), client_id: testClientId, hashtag: testTag)

  stubFeed = ->
    feedSpy = sinon.spy(window, 'Instafeed')

  beforeEach ->
    createDom()

  describe 'feed object', ->
    beforeEach ->
      stubFeed()
      createSubject()

    afterEach ->
      feedSpy.restore()

    it 'initializes instafeed on create', ->
      feedSpy.calledWithMatch(clientId: testClientId, tagName: testTag, limit: 16, get: 'tagged', sortBy: 'most-recent').should.equal(true)

  describe 'render', ->
    renderSpy = null

    beforeEach ->
      stubFeed()
      renderSpy = sinon.spy(RollFindr.Views.InstaFeedView.prototype, 'render')
      createSubject()

    afterEach ->
      feedSpy.restore()

    it 'renders itself on create', ->
      renderSpy.callCount.should.equal(1)

  describe 'load button', ->
    nextSpy = null
    beforeEach ->
      nextSpy = sinon.spy(subject.feed, 'next')

    afterEach ->
      nextSpy.restore()

    describe 'when there are more items', ->
      beforeEach ->
        sinon.stub(subject.feed, 'hasNext').returns(true)
        subject.afterLoadCallback()

      afterEach ->
        subject.feed.hasNext.restore()

      it 'is displayed', ->
        $('.load-more').should.be.visible

      it 'loads more items on click', ->
        subject.loadClicked()
        nextSpy.callCount.should.equal(1)

    describe 'when there are no more items', ->
      beforeEach ->
        sinon.stub(subject.feed, 'hasNext').returns(false)
        subject.afterLoadCallback()

      afterEach ->
        subject.feed.hasNext.restore()

      it 'is hidden', ->
        subject.$('.load-more').should.not.be.visible

    it 'is disabled on click', ->
      subject.loadClicked()
      subject.$('.load-more').should.be.disabled

