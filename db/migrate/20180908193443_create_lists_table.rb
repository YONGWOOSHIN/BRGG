class CreateListsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :lists do |t|
      t.integer :date
      t.string  :content
      t.integer :index
      t.integer :complete_check
      t.integer :revision_check
    end
  end
end
