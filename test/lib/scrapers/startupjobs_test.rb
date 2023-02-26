require "test_helper"

class Scrapers::StartupjobsTest < ActiveSupport::TestCase
  describe "#url" do
    test "returns url" do
      assert_equal Scrapers::Startupjobs.new.url, "https://startup.jobs"
    end
  end

  describe "#headers" do
    test "returns empty hash" do
      assert_equal Scrapers::Startupjobs.new.headers, {}
    end
  end

  describe "#parse" do
    test "populate jobs from body" do
      scraper = Scrapers::Startupjobs.new
      filepath = Rails.root.join(file_fixture("startupjobs_example.html"))
      body = File.read(filepath)
      expected_jobs = [
        {
          pid: "fake_path_1",
          name: "Fake name 1",
          url: "https://startup.jobs/fake_path_1",
          company: "Fake company 1",
          img_url: "fake image url 1"
        },
        {
          pid: "fake_path_2",
          name: "Fake name 2",
          url: "https://startup.jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2"
        },
        {
          pid: "fake_path_3",
          name: "Fake name 3",
          url: "https://startup.jobs/fake_path_3",
          company: "Fake company 3",
          img_url: "fake image url 3"
        }
      ]
      remote_select = Minitest::Mock.new
      remote_select.expect :click, nil, []
      network = Minitest::Mock.new
      network.expect :wait_for_idle, nil, []
      browser = Minitest::Mock.new
      browser.expect :go_to, nil, ["https://startup.jobs/ruby-jobs"]
      browser.expect :at_css, remote_select, ["#remote"]
      browser.expect :network, network, []
      browser.expect :body, body, []
      browser.expect :reset, nil, []
      browser.expect :quit, nil, []

      Ferrum::Browser.stub(:new, browser) do
        assert_equal scraper.call, expected_jobs
        assert_mock browser
        assert_mock network
        assert_mock remote_select
      end
    end
  end
end
