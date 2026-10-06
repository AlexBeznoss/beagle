require "test_helper"

class JobPosts::CleanupJobTest < ActiveJob::TestCase
  describe "#perform" do
    test "destroys old job posts" do
      travel_to 3.months.ago - 1.day
      expired = FactoryBot.create_list(:job_post, 3)
      LegacyBookmark.create!(job_post: expired.first, user_id: "legacy_user")
      travel_back
      to_be_left = FactoryBot.create_list(:job_post, 3)
      retained = LegacyBookmark.create!(job_post: to_be_left.first, user_id: "legacy_user")

      assert_difference "LegacyBookmark.count", -1 do
        JobPosts::CleanupJob.new.perform
      end
      assert LegacyBookmark.exists?(retained.id)

      job_posts = JobPost.all
      assert_equal 3, job_posts.count
      assert_equal job_posts.to_a.sort, to_be_left.sort
    end
  end
end
