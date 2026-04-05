FactoryBot.define do
  factory :activity do
    association :pod
    association :proposed_by, factory: :user
    occurred_on { Date.today + 3 }
    status { :planned }
  end
end
