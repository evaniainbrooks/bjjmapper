FactoryGirl.define do
  factory :user do
    sequence :name do |i|
      "Test User #{i}"
    end
    uid '1234'
    email 'test@rollfindr.com'
    provider :twitter

    factory :white_belt do
      belt_rank 'white'
    end
    factory :blue_belt do
      belt_rank 'blue'
    end
    factory :black_belt do
      belt_rank 'black'
    end

    factory :instructor_with_students do
      after(:create) do |instance|
        3.times do
          instance.lineal_children << create(:user)
        end
      end
    end
  end
end
