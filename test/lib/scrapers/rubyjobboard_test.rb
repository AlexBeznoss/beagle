require "test_helper"

class Scrapers::RubyjobboardTest < ActiveSupport::TestCase
  describe "#url" do
    test "returns url" do
      assert_equal Scrapers::Rubyjobboard.new.url, "https://www.rubyjobboard.com/newest-ruby-on-rails-jobs"
    end
  end

  describe "#headers" do
    test "returns empty hash" do
      assert_equal Scrapers::Rubyjobboard.new.headers, {}
    end
  end

  describe "#parse" do
    test "populate jobs from body" do
      scraper = Scrapers::Rubyjobboard.new
      filepath = Rails.root.join(file_fixture("rubyjobboard_example.html"))
      body = File.read(filepath)
      expected_jobs = [
        {
          pid: "fake_path_1",
          name: "Fake name 1",
          url: "https://www.rubyjobboard.com/jobs/fake_path_1",
          company: "Fake company 1",
          img_url: "fake image url 1",
          posted_at: 2.hours.ago.to_date
        },
        {
          pid: "fake_path_2",
          name: "Fake name 2",
          url: "https://www.rubyjobboard.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2",
          posted_at: 2.days.ago.to_date
        },
        {
          pid: "fake_path_3",
          name: "Fake name 3",
          url: "https://www.rubyjobboard.com/jobs/fake_path_3",
          company: "Fake company 3",
          img_url: "fake image url 3",
          posted_at: 8.days.ago.to_date
        }
      ]

      scraper.parse(body)

      assert_equal scraper.jobs, expected_jobs
    end
  end

  describe "#raise_no_jobs!" do
    test "raises exception with url" do
      scraper = Scrapers::Rubyjobboard.new

      assert_raises Scrapers::NoJobsFound, "No jobs found on #{scraper.url}" do
        scraper.raise_no_jobs!
      end
    end
  end
end
