FactoryGirl.define do

  factory :thing do
    sequence(:name) { |i| "Thing #{i}" }
  end

  factory :widget do
    sequence(:name) { |i| "Widget #{i}" }
  end

end