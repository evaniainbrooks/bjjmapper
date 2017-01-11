json.id result.id.to_s
json.name result.name.to_s
json.url team_path(result, ref: 'search')
