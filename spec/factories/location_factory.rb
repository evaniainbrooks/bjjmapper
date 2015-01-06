FactoryGirl.define do
  factory :location do
    title 'LakeCityBJJ'
    description 'A short test description'
    coordinates [80.0, 80.0]
    team

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
