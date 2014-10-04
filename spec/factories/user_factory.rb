FactoryGirl.define do
  factory :user do
    name 'Test User'
    uid '1234'
    email 'test@rollfindr.com'
    image 'testimg.jpg'
    provider :twitter
  end
end
