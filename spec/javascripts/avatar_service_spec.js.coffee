#= require spec_helper
#= require backbone/rollfindr
#= require avatar_service

describe 'App#AvatarService', ->
  it 'returns the path to the avatar service', ->
    RollFindr.AvatarService("BJJ Mapper").should.match(/BJJ%20Mapper\/image.png/)
