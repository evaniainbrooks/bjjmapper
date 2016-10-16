#= require spec_helper
#= require ext

describe 'Number#toRad', ->
  it "converts to radians", ->
    360.0.toRad().should.equal(360.0*Math.PI/180)

describe 'String#pluralize', ->
  it "returns a a pluralized string with the count", ->
    'world'.pluralize(5).should.equal('5 worlds')
  it "does not pluralize when the count is 1", ->
    'world'.pluralize(1).should.equal('1 world')
