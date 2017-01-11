json.array! @responses do |response|
  json.name response[:name]
  json.results(response[:results]) do |result|
    json.partial! response[:name], result: result
  end
end
