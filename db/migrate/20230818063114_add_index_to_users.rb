class AddIndexToUsers < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :registered_at, unique: true
  end
end
