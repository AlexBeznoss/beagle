class RemovePostedAtFromJobPost < ActiveRecord::Migration[7.0]
  def change
    remove_column :job_posts, :posted_at, :date
  end
end
