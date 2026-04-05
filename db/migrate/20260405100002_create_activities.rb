class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.bigint :pod_id, null: false
      t.bigint :proposed_by_id, null: false
      t.date :occurred_on, null: false
      t.string :status, null: false, default: "planned"

      t.timestamps
    end

    add_index :activities, :pod_id
    add_index :activities, :proposed_by_id
    add_foreign_key :activities, :pods
    add_foreign_key :activities, :users, column: :proposed_by_id
  end
end
