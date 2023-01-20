require "test_helper"

class Scrapers::GorailsTest < ActiveSupport::TestCase
  describe "#url" do
    test "returns url" do
      assert_equal Scrapers::Gorails.new.url, "https://jobs.gorails.com/"
    end
  end

  describe "#headers" do
    test "returns empty hash" do
      assert_equal Scrapers::Gorails.new.headers, {}
    end
  end

  describe "#parse" do
    test "populate jobs from body" do
      scraper = Scrapers::Gorails.new
      filepath = Rails.root.join(file_fixture("gorails_example.html"))
      body = File.read(filepath)
      expected_jobs = [
        {
          pid: "fake_path_1",
          name: "Fake name 1",
          url: "https://jobs.gorails.com/jobs/fake_path_1",
          company: "Fake company 1",
          img_url: "fake image url 1",
          location: "North America, Europe"
        },
        {
          pid: "fake_path_2",
          name: "Fake name 2",
          url: "https://jobs.gorails.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2",
          location: nil
        },
        {
          pid: "fake_path_3",
          name: "Fake name 3",
          url: "https://jobs.gorails.com/jobs/fake_path_3",
          company: "Fake company 3",
          img_url: nil,
          location: "North America"
        }
      ]

      scraper.parse(body)

      assert_equal scraper.jobs, expected_jobs
    end
  end

  describe "#raise_no_jobs!" do
    test "raises exception with url" do
      scraper = Scrapers::Gorails.new

      assert_raises Scrapers::NoJobsFound, "No jobs found on #{scraper.url}" do
        scraper.raise_no_jobs!
      end
    end
  end
end
