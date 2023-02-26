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

  describe "#call" do
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
          location: "Europe"
        },
        {
          pid: "fake_path_2",
          name: "Fake name 2",
          url: "https://rubyonremote.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2",
          location: nil
        },
        {
          pid: "fake_path_3",
          name: "Fake name 3",
          url: "https://rubyonremote.com/jobs/fake_path_3",
          company: "Fake company 3",
          img_url: "fake image url 3",
          location: "North America"
        }
      ]

      result = scraper.call(body)

      assert_equal result, expected_jobs
    end
  end
end
