FactoryGirl.define do
  factory :event do
    title 'test event'
    description 'test event description'
    starting 2.hours.ago
    ending 1.hours.ago
    location
    user
  end
end
