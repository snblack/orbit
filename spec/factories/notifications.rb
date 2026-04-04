FactoryBot.define do
  factory :notification do
    association :user
    association :pod
    message { "Вы вошли в группу" }
    read    { false }
  end
end
