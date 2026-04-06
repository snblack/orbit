FactoryBot.define do
  factory :message do
    association :pod
    association :user
    body { "Тестовое сообщение" }
  end
end
