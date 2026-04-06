FactoryBot.define do
  factory :pod do
    status { "inactive" }

    trait :active do
      status { "active" }
    end
  end
end
