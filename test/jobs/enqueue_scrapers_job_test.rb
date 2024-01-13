require "test_helper"

class EnqueueScrapersJobTest < ActiveJob::TestCase
  describe "#perform" do
    test "enqueue async jobs" do
      [
        ["gorails"],
        ["remoteok"],
        ["startupjobs"],
        ["weworkremotely"],
        # NOTE: uncomment when rubyjobboard get up
        # ["rubyjobboard"],
        ["rubyonremote"]
      ].sort

      assert_enqueued_with(job: ScrapeJob, args: ["gorails"]) do
        assert_enqueued_with(job: ScrapeJob, args: ["remoteok"]) do
          assert_enqueued_with(job: ScrapeJob, args: ["startupjobs"]) do
            assert_enqueued_with(job: ScrapeJob, args: ["weworkremotely"]) do
              assert_enqueued_with(job: ScrapeJob, args: ["rubyonremote"]) do
                EnqueueScrapersJob.new.perform
              end
            end
          end
        end
      end
    end
  end
end
