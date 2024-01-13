require "test_helper"

class JobPosts::CleanupJobTest < ActiveJob::TestCase
  describe "#perform" do
    test "destroys old job posts" do
      travel_to 3.months.ago - 1.day
      FactoryBot.create_list(:job_post, 3)
      travel_back
      to_be_left = FactoryBot.create_list(:job_post, 3)

      JobPosts::CleanupJob.new.perform

      job_posts = JobPost.all
      assert_equal 3, job_posts.count
      assert_equal job_posts.to_a.sort, to_be_left.sort
    end
  end
end
