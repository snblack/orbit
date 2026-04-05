FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:display_name) { |n| "User #{n}" }
    password { "password" }
    confirmed_at { Time.current }
    onboarding_completed { true }
    bio { nil }
    interests { [] }
    latitude  { 53.9 }
    longitude { 27.5 }
    life_phase       { :student }
    social_style     { :introvert }
    friendship_goal  { :growth }
    openness_level   { :moderate }
    social_frequency { :once_week }
    schedule_preference { {} }
  end
end
