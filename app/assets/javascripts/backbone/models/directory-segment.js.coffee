class RollFindr.Models.DirectorySegment extends Backbone.Model
  defaults:
    name: null

  initialize: ->
    locationsCollection = new RollFindr.Collections.LocationsCollection(arguments[0].locations)
    this.set('locations', locationsCollection)

    id = @get('id')
    if @get('parent_segment')
      parent_segment = @get('parent_segment')
      parent_segment = new RollFindr.Models.DirectorySegment(parent_segment)
      @set('parent_segment', parent_segment)

