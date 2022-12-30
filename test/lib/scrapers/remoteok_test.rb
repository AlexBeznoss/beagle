require "test_helper"

class Scrapers::RemoteokTest < ActiveSupport::TestCase
  describe "#url" do
    test "returns url" do
      assert_equal Scrapers::Remoteok.new.url, "https://remoteok.com/remote-ruby-jobs.json"
    end
  end

  describe "#headers" do
    test "returns empty hash" do
      assert_equal Scrapers::Remoteok.new.headers, {Accept: "application/json"}
    end
  end

  describe "#parse" do
    test "populate jobs from body" do
      scraper = Scrapers::Remoteok.new
      filepath = Rails.root.join(file_fixture("remoteok_example.json"))
      body = File.read(filepath)
      expected_jobs = [
        {
          pid: "111111",
          name: "Fake name 1",
          url: "https://remoteOK.com/jobs/fake_path_1",
          company: "Fake company 1",
          img_url: "fake image url 1",
          location: "North America, Europe",
          posted_at: Date.parse("2022-12-18")
        },
        {
          pid: "222222",
          name: "Fake name 2",
          url: "https://remoteOK.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2",
          location: nil,
          posted_at: Date.parse("2022-12-19")
        },
        {
          pid: "333333",
          name: "Fake name 3",
          url: "https://remoteOK.com/jobs/fake_path_3",
          company: "Fake company 3",
          img_url: "fake image url 3",
          location: "North America",
          posted_at: Date.parse("2022-12-20")
        }
      ]

      scraper.parse(body)

      assert_equal scraper.jobs, expected_jobs
    end
  end

  describe "#raise_no_jobs!" do
    test "raises exception with url" do
      scraper = Scrapers::Remoteok.new

      assert_raises Scrapers::NoJobsFound, "No jobs found on #{scraper.url}" do
        scraper.raise_no_jobs!
      end
    end
  end
end
