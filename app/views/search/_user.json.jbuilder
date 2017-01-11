json.id result.id.to_s
json.name result.name
json.nickname result.nickname
json.belt_rank result.belt_rank
json.stripe_rank result.stripe_rank
json.full_lineage []
json.url user_path(result, ref: 'search')
