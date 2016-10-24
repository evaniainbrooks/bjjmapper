FactoryGirl.define do
  factory :review do
    author_name 'Hentry'
    author_link 'google.com/henry'
    src 'Google'
    body 'test review'
    rating 4
    location
    user
  end
end
