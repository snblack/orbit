class CreatePods < ActiveRecord::Migration[8.1]
  def change
    create_table :pods do |t|
      t.string :status, null: false, default: "inactive"

      t.timestamps
    end
  end
end
