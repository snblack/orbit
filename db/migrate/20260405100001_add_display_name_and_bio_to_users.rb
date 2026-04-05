class AddDisplayNameAndBioToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :display_name, :string, null: false, default: ""
    add_column :users, :bio, :text
  end
end
