require "test_helper"

class Scrapers::RubyonremoteTest < ActiveSupport::TestCase
  describe "#url" do
    test "returns url" do
      assert_equal Scrapers::Rubyonremote.new.url, "https://rubyonremote.com"
    end
  end

  describe "#headers" do
    test "returns empty hash" do
      assert_equal Scrapers::Rubyonremote.new.headers, {Accept: "text/vnd.turbo-stream.html"}
    end
  end

  describe "#parse" do
    test "populate jobs from body" do
      scraper = Scrapers::Rubyonremote.new
      filepath = Rails.root.join(file_fixture("rubyonremote_example.turbo.html"))
      body = File.read(filepath)
      expected_jobs = [
        {
          pid: "fake_path_1",
          name: "Fake name 1",
          url: "https://rubyonremote.com/jobs/fake_path_1",
          company: "Fake company 1",
          img_url: "fake image url 1",
          location: "Europe",
          posted_at: Date.parse("#{Time.zone.now.year}-12-18")
        },
        {
          pid: "fake_path_2",
          name: "Fake name 2",
          url: "https://rubyonremote.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2",
          location: nil,
          posted_at: Date.parse("#{Time.zone.now.year}-12-19")
        },
        {
          pid: "fake_path_3",
          name: "Fake name 3",
          url: "https://rubyonremote.com/jobs/fake_path_3",
          company: "Fake company 3",
          img_url: "fake image url 3",
          location: "North America",
          posted_at: Date.parse("#{Time.zone.now.year}-12-20")
        }
      ]

      scraper.parse(body)

      assert_equal scraper.jobs, expected_jobs
    end
  end

  describe "#raise_no_jobs!" do
    test "raises exception with url" do
      scraper = Scrapers::Rubyonremote.new

      assert_raises Scrapers::NoJobsFound, "No jobs found on #{scraper.url}" do
        scraper.raise_no_jobs!
      end
    end
  end
end
