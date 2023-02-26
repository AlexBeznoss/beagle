require "test_helper"

class EnqueueScrapersJobTest < ActiveSupport::TestCase
  describe "#perform" do
    test "enqueue async jobs" do
      expected_args = [
        ["gorails"],
        ["remoteok"],
        ["startupjobs"],
        # NOTE: uncomment when rubyjobboard get up
        # ["rubyjobboard"],
        ["rubyonremote", 1],
        ["rubyonremote", 2],
        ["rubyonremote", 3]
      ].sort

      assert_equal 0, ScrapeJob.jobs.size

      EnqueueScrapersJob.new.perform

      assert_equal 6, ScrapeJob.jobs.size
      assert_equal expected_args, ScrapeJob.jobs.pluck("args").sort
    end
  end
end
