#= require spec_helper

describe "Application", ->
  it "creates a global variable for the application namespace", ->
    should.exist(window.RollFindr)
    should.exist(window.RollFindr.Models)
    should.exist(window.RollFindr.Collections)
    should.exist(window.RollFindr.Views)
