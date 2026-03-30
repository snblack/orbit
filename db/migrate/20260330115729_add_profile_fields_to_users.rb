class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :life_phase, :integer
    add_column :users, :social_style, :integer
    add_column :users, :friendship_goal, :integer
    add_column :users, :schedule_preference, :jsonb, default: {}
    add_column :users, :social_frequency, :integer
    add_column :users, :openness_level, :integer
    add_column :users, :interests, :string, array: true, default: []
    add_column :users, :location_district, :string
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :users, :onboarding_completed, :boolean, default: false, null: false
  end
end
