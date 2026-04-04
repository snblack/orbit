# Seed data for testing rails matching:run
# Idempotent: cleans matching data and seed users before recreating them

Notification.delete_all
PodMembership.delete_all
Pod.delete_all
User.where("email LIKE 'seed\\_%'").delete_all

20.times do |i|
  User.create!(
    email: "seed_#{i + 1}@example.com",
    password: "password",
    confirmed_at: Time.current,
    onboarding_completed: true,
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

puts "Created #{User.where("email LIKE 'seed\\_%'").count} seed users"
puts "Run 'rails matching:run' to test the matching algorithm"
