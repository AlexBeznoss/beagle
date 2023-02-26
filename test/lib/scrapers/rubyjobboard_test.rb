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
          img_url: "fake image url 1"
        },
        {
          pid: "fake_path_2",
          name: "Fake name 2",
          url: "https://www.rubyjobboard.com/jobs/fake_path_2",
          company: "Fake company 2",
          img_url: "fake image url 2"
        },
        {
          pid: "fake_path_3",
          name: "Fake name 3",
          url: "https://www.rubyjobboard.com/jobs/fake_path_3",
          company: "Fake company 3",
          img_url: "fake image url 3"
        }
      ]

      rb_mock = Minitest::Mock.new
      rb_mock.expect :call, body, [scraper.url, scraper.headers]

      Scrapers.stub_const(:RequestBody, rb_mock) do
        assert_equal scraper.call, expected_jobs
        assert_mock rb_mock
      end
    end
  end
end
