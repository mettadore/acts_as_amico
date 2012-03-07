require 'uuidtools'
FactoryGirl.define do

  factory :user do
    sequence(:name) { |i| "Regular User #{i}" }
  end

  factory :admin do
    sequence(:name) { UUIDTools::UUID.random_create.to_str }
  end

end