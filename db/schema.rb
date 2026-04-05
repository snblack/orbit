# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_05_100002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "occurred_on", null: false
    t.bigint "pod_id", null: false
    t.bigint "proposed_by_id", null: false
    t.string "status", default: "planned", null: false
    t.datetime "updated_at", null: false
    t.index ["pod_id"], name: "index_activities_on_pod_id"
    t.index ["proposed_by_id"], name: "index_activities_on_proposed_by_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message", null: false
    t.bigint "pod_id", null: false
    t.boolean "read", default: false, null: false
    t.bigint "user_id", null: false
    t.index ["pod_id"], name: "index_notifications_on_pod_id"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "pod_memberships", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "pod_id", null: false
    t.bigint "user_id", null: false
    t.index ["pod_id", "user_id"], name: "index_pod_memberships_on_pod_id_and_user_id", unique: true
    t.index ["pod_id"], name: "index_pod_memberships_on_pod_id"
    t.index ["user_id"], name: "index_pod_memberships_on_user_id"
  end

  create_table "pods", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "status", default: "inactive", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "display_name", default: "", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "friendship_goal"
    t.string "interests", default: [], array: true
    t.float "latitude"
    t.integer "life_phase"
    t.string "location_district"
    t.float "longitude"
    t.boolean "onboarding_completed", default: false, null: false
    t.integer "openness_level"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.jsonb "schedule_preference", default: {}
    t.integer "social_frequency"
    t.integer "social_style"
    t.string "unconfirmed_email"
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "pods"
  add_foreign_key "activities", "users", column: "proposed_by_id"
  add_foreign_key "notifications", "pods"
  add_foreign_key "notifications", "users"
  add_foreign_key "pod_memberships", "pods"
  add_foreign_key "pod_memberships", "users"
end
