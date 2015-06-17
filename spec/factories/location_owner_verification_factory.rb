FactoryGirl.define do
  factory :location_owner_verification do
    user
    location
    email 'evaniainbrooks@gmail.com'
  end
end
