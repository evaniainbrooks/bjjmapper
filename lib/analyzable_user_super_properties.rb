require 'analyzable'

module RollFindr
  module AnalyzableUserSuperProperties
    protected

    def analytics_super_properties
      agent = Agent.new(request.user_agent || "")
      props = {
        browser_name: agent.name,
        browser_version: agent.version,
        browser_engine: agent.engine,
        browser_os: agent.os,
        browser_engine_version: agent.engine_version,
        user_agent: request.user_agent,
        accept_language: request.env['HTTP_ACCEPT_LANGUAGE'],
        ref: params.fetch(:ref, '')
      }

      defined?(super) ? super.merge(props) : props
    end
  end
end

