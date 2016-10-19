require 'location_fetch_client'

RollFindr::LocationFetchService = RollFindr::LocationFetchClient.new(
  RollFindr::Application.config.location_fetch_service_host,
  RollFindr::Application.config.location_fetch_service_port
)
