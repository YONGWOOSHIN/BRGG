class CreateCommentsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :user_id
      t.date :comment_date
      t.string  :content
      #t.boolean :revision_check
    end
  end
end
