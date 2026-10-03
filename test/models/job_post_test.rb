require "test_helper"

class JobPostTest < ActiveSupport::TestCase
  describe ".for_cleanup" do
    test "returns job_posts older than 3 month ago" do
      travel_to 3.months.ago - 1.day
      to_be_deleted = FactoryBot.create(:job_post)
      travel_back
      to_be_left = FactoryBot.create(:job_post)

      result = JobPost.for_cleanup

      assert_equal 1, result.count
      assert_includes result, to_be_deleted
      assert_not_includes result, to_be_left
    end
  end
end
