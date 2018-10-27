class CreateCommentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :date
      t.string  :content
      t.integer :revision_check
    end
  end
end
