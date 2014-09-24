class RollFindr.Models.Team extends Backbone.Model
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
