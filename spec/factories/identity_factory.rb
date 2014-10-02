# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identity do
    name "test user"
    email "test@example.com"
    password_digest "12345"
  end
end
