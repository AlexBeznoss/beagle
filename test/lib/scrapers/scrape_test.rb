require "test_helper"

class Scrapers::ScrapeTest < ActiveSupport::TestCase
  PROVIDER_MAP = {
    "gorails" => Scrapers::Gorails,
    "remoteok" => Scrapers::Remoteok,
    "rubyonremote" => Scrapers::Rubyonremote,
    "startupjobs" => Scrapers::Startupjobs
  }
  describe ".call" do
    describe "when provider is not supported" do
      test "raises exception" do
        assert_raises(StandardError, "Provider nothing is not supported") do
          Scrapers::Scrape.call("nothing")
        end
      end
    end

    PROVIDER_MAP.keys.each do |provider|
      describe "when provider is #{provider}" do
        test "returns result of scraper call" do
          page = rand(20)
          expected_result = ["first job", "second job"]

          scraper_instance_mock = Minitest::Mock.new
          scraper_instance_mock.expect :call, expected_result, []

          scraper_mock = Minitest::Mock.new
          scraper_mock.expect :new, scraper_instance_mock, [page]

          klass_name = PROVIDER_MAP[provider].to_s.split("::").last.to_sym
          Scrapers.stub_const(klass_name, scraper_mock) do
            result = Scrapers::Scrape.call(provider, page)

            assert_equal expected_result, result
            assert_mock scraper_instance_mock
            assert_mock scraper_mock
          end
        end

        test "raises error when not jobs" do
          page = rand(20)
          url = "fake url"
          result = []

          scraper_instance_mock = Minitest::Mock.new
          scraper_instance_mock.expect :url, url
          scraper_instance_mock.expect :call, result, []

          scraper_mock = Minitest::Mock.new
          scraper_mock.expect :new, scraper_instance_mock, [page]

          klass_name = PROVIDER_MAP[provider].to_s.split("::").last.to_sym
          Scrapers.stub_const(klass_name, scraper_mock) do
            assert_raises(Scrapers::Scrape::NoJobsFound, "No jobs found on #{url}") do
              Scrapers::Scrape.call(provider, page)
            end
          end
        end
      end
    end
  end
end
