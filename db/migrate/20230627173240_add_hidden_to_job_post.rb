class AddHiddenToJobPost < ActiveRecord::Migration[7.0]
  def change
    add_column :job_posts, :hidden, :boolean, null: false, default: false
    add_index :job_posts, :hidden, where: "hidden is false"
  end
end
