FactoryGirl.define do
  factory :organization do
    sequence :name do |i|
      "Organization #{i}"
    end

    sequence :abbreviation do |i|
      "ORG#{i}"
    end

    email 'contact@website.org'
    website 'website.org'
  end
end
