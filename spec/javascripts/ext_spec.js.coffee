#= require spec_helper

describe 'Number#toRad', ->
  it "converts to radians", ->
    360.0.toRad().should.equal(360.0*Math.PI/180)


