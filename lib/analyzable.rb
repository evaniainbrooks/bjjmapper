require 'tracker'
require 'user-agent'

module RollFindr
  module Analyzable
    protected

    def tracker
      @tracker ||= Tracker.new(user_id, browser_properties)
    end

    def browser_properties
      agent = Agent.new(request.user_agent)
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
    end

    def user_id
      current_user.try(:to_param)
    end
  end
end
