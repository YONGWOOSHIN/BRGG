class CreateDevicesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.integer :user_id
      t.string  :os
      t.string  :device_name
    end
  end
end
