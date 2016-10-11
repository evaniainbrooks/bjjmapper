#= require spec_helper
#= require backbone/rollfindr

describe "Models.Location", ->
  locationId = "12345"
  subject = new RollFindr.Models.Location({id: locationId})

  it 'has many instructors', ->
    subject.get('instructors').should.be.an.instanceof(RollFindr.Collections.LocationInstructorsCollection)
    subject.get('instructors').location_id.should.equal(locationId)

  it 'has many reviews', ->
    subject.get('reviews').should.be.an.instanceof(RollFindr.Collections.ReviewsCollection)
    subject.get('reviews').location_id.should.equal(locationId)

  it 'has many events', ->
    subject.get('events').should.be.an.instanceof(RollFindr.Collections.LocationEventsCollection)
    subject.get('events').location_id.should.equal(locationId)


describe "Models.NearbyLocationsCollection", ->
  testLat = 80.0
  testLng = 88.0
  testReject = "12345"
  locationType = 1
  count = 3
  subject = new RollFindr.Collections.NearbyLocationsCollection({lat: testLat, lng: testLng, reject: testReject, location_type: [locationType], count: count})

  it 'has latitude, longitude and reject parameters', ->
    subject.lat.should.equal(testLat)
    subject.lng.should.equal(testLng)
    subject.reject.should.equal(testReject)

  it 'has a url', ->
    subject.url().should.equal(Routes.nearby_locations_path({lat: testLat, lng: testLng, reject: testReject, location_type: [locationType], count: count})

describe "Models.RecentLocationsCollection", ->
  testCount = 50
  subject = new RollFindr.Collections.RecentLocationsCollection({count: testCount})

  it 'has a count', ->
    subject.count.should.equal(testCount)

  it 'has a url', ->
    subject.url().should.equal(Routes.recent_locations_path({count: testCount}))

