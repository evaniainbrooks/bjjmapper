require 'website_status_client'

RollFindr::WebsiteStatusService = RollFindr::WebsiteStatusClient.new(
  RollFindr::Application.config.website_status_service_host,
  RollFindr::Application.config.website_status_service_port
)
