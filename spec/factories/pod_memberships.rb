FactoryBot.define do
  factory :pod_membership do
    association :pod
    association :user
  end
end
