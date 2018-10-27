class CreateUsersTable < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string  :user_name
      t.string  :mail
      t.integer :unique_key
      t.string  :device_name
    end
  end
end
