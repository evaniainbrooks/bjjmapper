json.lat map.lat
json.lng map.lng
json.zoom map.zoom
json.query map.query
json.geoquery map.geoquery
json.refresh map.refresh
json.event_type map.event_type
json.team map.team
json.location_type map.location_type
json.minZoom map.minZoom
json.geolocate map.geolocate
json.legend map.legend
json.location_count map.location_count
json.event_count map.event_count
json.locations map.locations, partial: 'locations/location_with_events', as: :location
