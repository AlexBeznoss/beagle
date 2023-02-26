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

  describe "#call" do
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
          location: "North America, Europe"
        },
        {
          pid: "222222",
          name: "Fake name 2",
          url: "https://remoteOK.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2",
          location: nil
        },
        {
          pid: "333333",
          name: "Fake name 3",
          url: "https://remoteOK.com/jobs/fake_path_3",
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
