class CreateDevicesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :devices do |t|
      t.string  :user_name
      t.string  :os
      t.string  :device_name
    end
  end
end
