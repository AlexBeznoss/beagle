class CreateJobPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :job_posts do |t|
      t.string :pid, null: false
      t.integer :provider, null: false
      t.string :name, null: false
      t.string :url, null: false
      t.string :company
      t.string :img_url
      t.string :location
      t.date :posted_at

      t.timestamps
    end

    add_index :job_posts, %i[provider pid], unique: true
  end
end
