module RollFindr
  class Tracker
    def initialize(user_id, super_properties = {})
      @user_id = user_id
      @super_properties = super_properties
    end

    def track(event, params = {})
      tracker.track(@user_id, event, @super_properties.merge(params))
    end

    def register(params)
      @super_properties.merge!(params)
    end

    def alias(new_id, old_id)
      tracker.alias(new_id, old_id)
      @user_id = new_id
    end

    private

    def tracker
      @tracker ||= Mixpanel::Tracker.new(Rails.configuration.mixpanel_key)
    end
  end
end
