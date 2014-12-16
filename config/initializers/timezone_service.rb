require 'timezone_client'

RollFindr::TimezoneService = RollFindr::TimezoneClient.new(
  RollFindr::Application.config.timezone_service_host,
  RollFindr::Application.config.timezone_service_port
)
