#= require spec_helper
#

describe "Models.Map", ->
  subject = new RollFindr.Models.Map()

  it 'has many locations', ->
    expect(subject.get('locations')).to.be.an.instanceof(RollFindr.Collections.LocationsCollection)

  it 'has a default center', ->
    expect(subject.get('center')).to.exist

  it 'has a default zoom', ->
    expect(subject.get('zoom')).to.exist

