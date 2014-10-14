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
  end
end
