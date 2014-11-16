module RollFindr
  class Tracker
    def initialize(user_id)
      @user_id = user_id
    end

    def track(event, params = {})
      tracker.track(@user_id, event, params)
    end

    private

    def tracker
      @tracker ||= Mixpanel::Tracker.new(Rails.configuration.mixpanel_key)
    end
  end
end
