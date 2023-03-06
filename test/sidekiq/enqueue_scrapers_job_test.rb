require "test_helper"

class EnqueueScrapersJobTest < ActiveSupport::TestCase
  describe "#perform" do
    test "enqueue async jobs" do
      expected_args = [
        ["gorails"],
        ["remoteok"],
        ["startupjobs"],
        ["weworkremotely"],
        # NOTE: uncomment when rubyjobboard get up
        # ["rubyjobboard"],
        ["rubyonremote", 1],
        ["rubyonremote", 2],
        ["rubyonremote", 3]
      ].sort

      lbm = lambda do |lock_name, &block|
        assert_equal "EnqueueScrapersJobLock", lock_name
        block.call
      end

      CallOnceLockService.stub :call, lbm do
        assert_changes "ScrapeJob.jobs.size", from: 0, to: 7 do
          EnqueueScrapersJob.new.perform
        end

        assert_equal expected_args, ScrapeJob.jobs.pluck("args").sort
      end
    end
  end

  describe "when lock not call block" do
    test "not enqueue jobs" do
      lbm = lambda do |lock_name, &block|
        assert_equal "EnqueueScrapersJobLock", lock_name
      end

      CallOnceLockService.stub :call, lbm do
        assert_no_changes "ScrapeJob.jobs.size" do
          EnqueueScrapersJob.new.perform
        end
      end
    end
  end
end
