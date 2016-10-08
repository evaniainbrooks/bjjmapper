FactoryGirl.define do
  factory :event do
    title 'test event'
    description 'test event description'
    starting 2.hours.ago
    ending 1.hours.ago
    location
    association :modifier, factory: :user
    association :instructor, factory: :user
    association :organization, factory: :organization

    factory :tournament do
      event_type Event::EVENT_TYPE_TOURNAMENT
    end

    factory :seminar do
      event_type Event::EVENT_TYPE_SEMINAR
    end
  end
end
