#= require spec_helper
#= require backbone/rollfindr
#= require backbone/models/map
#= require backbone/models/location

describe "Models.Map", ->
  subject = new RollFindr.Models.Map()

  it 'has many locations', ->
    expect(subject.get('locations')).to.be.an.instanceof(RollFindr.Collections.LocationsCollection)

  it 'has a default center', ->
    expect(subject.get('lat')).to.exist
    expect(subject.get('lng')).to.exist

  it 'has a default zoom', ->
    expect(subject.get('zoom')).to.exist

