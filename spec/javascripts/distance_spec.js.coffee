#= require spec_helper
#= require ext

describe 'Math#circleDistance', ->
  p0 = {
    lat: ->
      44.64616
    lng: ->
      -63.573920
  }
  p1 = {
    lat: ->
      47.620973
    lng: ->
      122.347276
  }
  it 'returns the distance between two points', ->
    distance = Math.circleDistance(p0, p1)
    Math.floor(distance).should.equal(2756)
