class CreatePodMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :pod_memberships do |t|
      t.references :pod,  null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :created_at, null: false
    end
    add_index :pod_memberships, [:pod_id, :user_id], unique: true
  end
end
