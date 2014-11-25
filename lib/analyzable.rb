require 'tracker'

module RollFindr
  module Analyzable
    protected

    def tracker
      @tracker ||= Tracker.new(user_id, analytics_super_properties)
    end

    def analytics_super_properties
      { __skip_tracking: current_user.try(:internal) }
    end

    def user_id
      current_user.try(:to_param)
    end
  end
end
