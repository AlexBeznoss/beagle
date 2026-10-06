require "test_helper"
require "ruby-clock"
require "ruby-clock/dsl"

class ScraperScheduleTest < ActiveJob::TestCase
  test "RubyOnRemote full crawl runs twice daily independently of the half-hourly batch" do
    jobs = {}
    schedule = Object.new
    schedule.define_singleton_method(:cron) { |expression, &block| jobs[expression] = block }
    clock = Struct.new(:schedule).new(schedule)
    RubyClock.stub(:instance, clock) { load Rails.root.join("Clockfile") }

    assert_equal ["*/30 * * * *", "0 0,12 * * * UTC", "5 0 * * *"], jobs.keys
    assert_enqueued_jobs(1, only: ScrapeJob) do
      assert_enqueued_with(job: ScrapeJob, args: ["rubyonremote"]) { jobs.fetch("0 0,12 * * * UTC").call }
    end
    cron = Fugit::Cron.parse("0 0,12 * * * UTC")
    assert_equal Time.utc(2026, 10, 7), cron.next_time(Time.utc(2026, 10, 6, 13)).to_t
    assert_equal Time.utc(2026, 10, 6, 12), cron.next_time(Time.utc(2026, 10, 6, 1)).to_t
  end
end
