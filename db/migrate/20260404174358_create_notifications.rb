class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pod,  null: false, foreign_key: true
      t.string  :message, null: false
      t.boolean :read, null: false, default: false
      t.datetime :created_at, null: false
    end
  end
end
