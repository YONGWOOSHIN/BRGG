class CreateTodosTable < ActiveRecord::Migration[5.2]
  def change
    create_table :todos do |t|
      t.integer :user_id
      t.date :todo_date #date or datetime
      t.string  :content
      t.integer :todo_index
      t.boolean :complete_check
      #t.boolean :revision_check
    end
  end
end
