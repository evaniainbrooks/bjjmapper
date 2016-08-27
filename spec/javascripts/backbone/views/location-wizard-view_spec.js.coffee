#= require spec_helper
#= require backbone/rollfindr
#= require avatar_service

describe 'Views.LocationWizardView', ->
  testTitle = "Test Location"
  testPhone = "2066614210"
  testAddress = {
    address: "14th Avenue, Saint Paul, NE 68873, USA"
    street: "14th Ave"
    postal_code: "98109"
    city: "Saint Paul"
    state: "Nebraska"
    country: "United States"
    lat: "41.234"
    lng: "-98.517"
  }

  testNearbyLocation = {
    city: "Saint Paul"
    country: "United States"
    image: "123.jpg"
    title: "Test Location"
    team_name: "Test Team"
    phone: "902-434-4343"
    postal_code: "68873"
    state: "Nebraska"
    street: "14th AVE NE"
  }

  subject = null

  setupDom = ->
    $('body').html('')
    wizard = $('body').addHtml('div', { class: 'wizard' })
    wizard.addHtml('button', class: 'btn-next')
    wizard.addHtml('button', class: 'btn-prev')

  setupFakeServer = ->
    this.server = sinon.fakeServer.create()
    geocodeResponse = [
      200,
      {'Content-Type': 'application/json'},
      JSON.stringify([testAddress])
    ]
    this.server.respondWith(
      'GET',
      Routes.geocoder_path({query: testAddress.street}),
      geocodeResponse
    )

    nearbyResponse = [
      200,
      {'Content-Type': 'application/json'},
      JSON.stringify([testNearbyLocation])
    ]
    this.server.respondWith(
      'GET',
      Routes.nearby_locations_path({reject: '', lat: testAddress.lat, lng: testAddress.lng}),
      nearbyResponse
    )

  beforeEach ->
    setupDom()
    setupFakeServer()
    $.prototype.wizard = sinon.spy()
    subject = new RollFindr.Views.LocationWizardView(el: $('.wizard'))

  it 'selects the .wizard element by default', ->
    subject.$el.should.have.class('wizard')

  describe 'fuelux wizard widget', ->
    it 'initializes the widget on create', ->
      $.prototype.wizard.callCount.should.equal(1)

  describe 'Step 1', ->
    beforeEach ->
      subject.$el.addHtml('input', name: 'location[title]')

    it '.next button is initially disabled with type=button', ->
      $('.btn-next', subject.$el).should.have.prop('disabled', true)
      $('.btn-next', subject.$el).should.have.prop('type', 'button')

    describe 'Step 2 transition', ->
      beforeEach ->
        subject.$el.addHtml('input', name: 'location[title]')

      it '.next is enabled when a title is entered', ->
        $('input[name="location[title]"]').val(testTitle).trigger('change')
        $('.btn-next', subject.$el).should.have.prop('disabled', false)

      it '.next is disabled after pressed', ->
        sinon.stub(subject, 'currentStep').returns(2)

        $('.btn-next', subject.$el).prop('disabled', false)
        $('.btn-next', subject.$el).trigger('click')
        $('.btn-next', subject.$el).should.have.prop('disabled', true)

      describe 'Step 3 transition', ->
        searchForAddress = ->
          e = $.Event('keyup', which: 13, keyCode: 13)
          $('#full_address', subject.$el).val(testAddress.street).trigger(e)
          server.respond()

        beforeEach ->
          subject.$el.addHtml('input', id: 'full_address')
          subject.$el.addHtml('input', name: 'location[postal_code]')
          subject.$el.addHtml('input', name: 'location[street]')

        it '.next is enabled when an address is selected', ->
          searchForAddress()

          $('.btn-next', subject.$el).should.have.prop('disabled', false)

        it 'populates the address fields after searching for the address', ->
          searchForAddress()

          $('[name="location[postal_code]"]', subject.$el).should.have.value(testAddress.postal_code)
          $('[name="location[street]"]', subject.$el).should.have.value(testAddress.street)

        describe 'Nearby Locations', ->
          beforeEach ->
            $(subject.$el).addHtml('div', class: 'nearby-locations').addHtml('div', class: 'items')

            searchForAddress()
            server.respond()

          xit 'shows nearby locations', ->
            $('.nearby-locations .items').html().should.match(new RegExp(testNearbyLocation.title))

        it '.next is disabled after press', ->
          sinon.stub(subject, 'currentStep').returns(3)

          $('.btn-next', subject.$el).prop('disabled', false)
          $('.btn-next', subject.$el).trigger('click')
          $('.btn-next', subject.$el).should.have.prop('disabled', true)


