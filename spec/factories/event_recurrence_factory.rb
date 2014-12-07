FactoryGirl.define do
  factory :event_recurrence do
    recurrence_rule "---\n:validations: {}\n:rule_type: IceCube::DailyRule\n:interval: 1\n:count: 10\n"
  end
end
