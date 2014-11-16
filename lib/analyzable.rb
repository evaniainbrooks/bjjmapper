require 'tracker'

module RollFindr
  module Analyzable
    protected

    def tracker
      @tracker ||= Tracker.new(user_id)
    end

    def user_id
      current_user.try(:to_param)
    end
  end
end
