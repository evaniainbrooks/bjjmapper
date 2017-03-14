FactoryGirl.define do
  factory :location do
    sequence :title do |i|
      "Academy#{i}"
    end
    description 'A short test description'
    coordinates [80.0, 80.0]
    country 'Canada'
    city 'Halifax'
    loctype Location::LOCATION_TYPE_ACADEMY

    after(:build) do |instance|
      RSpec::Mocks.with_temporary_scope do
        RollFindr::LocationFetchService.stub(:search).and_return(true)
      end
    end

    factory :event_venue do
      loctype Location::LOCATION_TYPE_EVENT_VENUE
    end

    factory :event_venue_with_tournament do
      loctype Location::LOCATION_TYPE_EVENT_VENUE
      after(:create) do |instance|
        instance.events << create(:tournament)
      end
    end

    factory :event_venue_with_seminar do
      loctype Location::LOCATION_TYPE_EVENT_VENUE
      after(:create) do |instance|
        instance.events << create(:seminar)
      end
    end

    factory :location_with_instructors do
      after(:create) do |instance|
        3.times do
          instance.instructors << create(:user)
        end
      end
    end
    factory :location_with_reviews do
      after(:create) do |instance|
        3.times do
          review = build(:review, location: instance)
          instance.reviews << review
        end
      end
    end
    factory :location_with_many_reviews do
      after(:create) do |instance|
        20.times do
          review = build(:review, location: instance)
          instance.reviews << review
        end
      end
    end
  end
end
