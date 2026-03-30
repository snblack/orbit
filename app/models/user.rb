class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  enum :life_phase, {
    recently_moved: 0,
    career_change: 1,
    new_parent: 2,
    remote_worker: 3,
    student: 4,
    retired: 5,
    other: 6
  }

  enum :social_style, {
    introvert: 0,
    ambivert: 1,
    extrovert: 2
  }

  enum :friendship_goal, {
    support: 0,
    growth: 1,
    fun: 2,
    intellectual: 3
  }

  enum :social_frequency, {
    once_week: 0,
    two_three_week: 1,
    daily: 2
  }

  enum :openness_level, {
    surface: 0,
    moderate: 1,
    deep: 2
  }

  # Onboarding step validations (activated via context)
  validates :life_phase,      presence: true, on: :onboarding_life_phase
  validates :social_style,    presence: true, on: :onboarding_values
  validates :friendship_goal, presence: true, on: :onboarding_values
  validates :openness_level,  presence: true, on: :onboarding_values
  validates :social_frequency, presence: true, on: :onboarding_rhythm
  validates :location_district, presence: true, on: :onboarding_location,
            unless: -> { latitude.present? && longitude.present? }
end
