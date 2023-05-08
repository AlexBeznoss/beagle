class CreateBookmarks < ActiveRecord::Migration[7.0]
  def change
    create_table :bookmarks do |t|
      t.references :job_post, null: false, foreign_key: true
      t.string :user_id, null: false

      t.timestamps
    end

    add_index :bookmarks, %i[job_post_id user_id], unique: true
  end
end
