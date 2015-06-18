#= require spec_helper
#= require backbone/rollfindr
#= require avatar_service

describe 'App#AvatarService', ->
  it 'returns the path to the avatar service', ->
    RollFindr.AvatarService("BJJ Mapper").should.match(/BJJ%20Mapper\/image.png/)
  it 'replaces special characters /?&', ->
    RollFindr.AvatarService("B?J&J/Mapper").should.match(/B%20J%20J%20Mapper\/image.png/)
