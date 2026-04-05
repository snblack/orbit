# Seed data — idempotent
Activity.delete_all
Notification.delete_all
PodMembership.delete_all
Pod.delete_all
User.where(email: %w[alice@example.com bob@example.com
                     inactive_user@example.com inactive_buddy@example.com]).delete_all
User.where("email LIKE 'seed\\_%'").delete_all

# Активные участники
alice = User.create!(
  email: "alice@example.com",
  password: "password",
  confirmed_at: Time.current,
  onboarding_completed: true,
  display_name: "Alice Smith",
  bio: "Люблю читать и путешествовать",
  latitude: 53.9,
  longitude: 27.5,
  life_phase: :recently_moved,
  social_style: :ambivert,
  friendship_goal: :growth,
  openness_level: :moderate,
  social_frequency: :once_week,
  schedule_preference: { "sat" => true },
  interests: %w[books travel coffee]
)

bob = User.create!(
  email: "bob@example.com",
  password: "password",
  confirmed_at: Time.current,
  onboarding_completed: true,
  display_name: "Bob Jones",
  bio: "Занимаюсь спортом, интересуюсь технологиями",
  latitude: 53.91,
  longitude: 27.51,
  life_phase: :remote_worker,
  social_style: :extrovert,
  friendship_goal: :fun,
  openness_level: :deep,
  social_frequency: :two_three_week,
  schedule_preference: { "fri" => true },
  interests: %w[fitness tech gaming]
)

# Неактивные участники
inactive_user = User.create!(
  email: "inactive_user@example.com",
  password: "password",
  confirmed_at: Time.current,
  onboarding_completed: true,
  display_name: "Carl New",
  latitude: 53.88,
  longitude: 27.48,
  life_phase: :student,
  social_style: :introvert,
  friendship_goal: :intellectual,
  openness_level: :surface,
  social_frequency: :once_week,
  schedule_preference: {}
)

inactive_buddy = User.create!(
  email: "inactive_buddy@example.com",
  password: "password",
  confirmed_at: Time.current,
  onboarding_completed: true,
  display_name: "Dana Park",
  latitude: 53.89,
  longitude: 27.49,
  life_phase: :career_change,
  social_style: :ambivert,
  friendship_goal: :support,
  openness_level: :moderate,
  social_frequency: :once_week,
  schedule_preference: {}
)

# Активный Pod
active_pod = Pod.create!(status: "active", created_at: 14.days.ago)
PodMembership.create!(pod: active_pod, user: alice)
PodMembership.create!(pod: active_pod, user: bob)

# Неактивный Pod
inactive_pod = Pod.create!(status: "inactive")
PodMembership.create!(pod: inactive_pod, user: inactive_user)
PodMembership.create!(pod: inactive_pod, user: inactive_buddy)

# Активности для активного Pod
Activity.create!(
  pod: active_pod,
  proposed_by: alice,
  occurred_on: 10.days.ago,
  status: "completed"
)

Activity.create!(
  pod: active_pod,
  proposed_by: bob,
  occurred_on: 3.days.from_now,
  status: "planned"
)

# Seed-пользователи для matching
20.times do |i|
  User.create!(
    email: "seed_#{i + 1}@example.com",
    password: "password",
    confirmed_at: Time.current,
    onboarding_completed: true,
    display_name: "Seed User #{i + 1}",
    latitude:  53.9 + rand(-0.05..0.05),
    longitude: 27.5 + rand(-0.05..0.05),
    life_phase:          %i[student career_change remote_worker].sample,
    social_style:        %i[introvert ambivert extrovert].sample,
    friendship_goal:     %i[growth support fun intellectual].sample,
    openness_level:      %i[surface moderate deep].sample,
    social_frequency:    %i[once_week two_three_week daily].sample,
    schedule_preference: [{ "mon" => true }, { "wed" => true }, { "fri" => true }, {}].sample
  )
end

puts "Seed complete:"
puts "  Active pod: alice@example.com / bob@example.com (password)"
puts "  Inactive pod: inactive_user@example.com / inactive_buddy@example.com (password)"
puts "  #{User.where("email LIKE 'seed\\_%'").count} seed users for matching"
puts "Run 'rails matching:run' to test the matching algorithm"
