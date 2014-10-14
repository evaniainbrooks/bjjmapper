FactoryGirl.define do
  factory :user do
    sequence :name do |i|
      "Test User #{i}"
    end
    uid '1234'
    email 'test@rollfindr.com'
    image 'testimg.jpg'
    provider :twitter
  end
end
