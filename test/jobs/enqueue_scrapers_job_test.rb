require "test_helper"

class EnqueueScrapersJobTest < ActiveJob::TestCase
  test "half-hourly batch excludes the paid twice-daily provider" do
    EnqueueScrapersJob.new.perform
    scrape_jobs = enqueued_jobs.select { |job| job[:job] == ScrapeJob }
    assert_equal %w[gorails remoteok startupjobs weworkremotely], scrape_jobs.map { |job| job[:args].first }.sort
    assert_equal 4, scrape_jobs.size
  end
end
