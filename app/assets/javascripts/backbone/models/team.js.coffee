class RollFindr.Models.Team extends Backbone.Model
  initialize: ->
    id = this.get('id')
    instructors = @get('instructors')
    instructors = new RollFindr.Collections.TeamInstructorsCollection(instructors, {team_id: id})
    this.set('instructors', instructors)

  paramRoot: 'team'

  defaults:
    name: null
    description: null
    image: null
    parent_team_id: null
    id: null

class RollFindr.Collections.TeamsCollection extends Backbone.Collection
  model: RollFindr.Models.Team
  url: '/teams'
  sort_key: 'id'
  comparator:
    (item)->
      return item.get(this.sort_key)
  sortByField:
    (fieldName)->
      this.sort_key = fieldName
      this.sort()

