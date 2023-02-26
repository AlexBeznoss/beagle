require "test_helper"

class Scrapers::ScrapeTest < ActiveSupport::TestCase
  PROVIDER_MAP = {
    "gorails" => Scrapers::Gorails,
    "remoteok" => Scrapers::Remoteok,
    "rubyjobboard" => Scrapers::Rubyjobboard,
    "rubyonremote" => Scrapers::Rubyonremote
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
          url = "fake url"
          headers = {"header" => "fake"}
          body = "fake body"
          expected_result = ["first job", "second job"]

          request_mock = Minitest::Mock.new
          request_mock.expect :call, body, [url, headers]

          scraper_instance_mock = Minitest::Mock.new
          scraper_instance_mock.expect :url, url
          scraper_instance_mock.expect :headers, headers
          scraper_instance_mock.expect :call, expected_result, [body]

          scraper_mock = Minitest::Mock.new
          scraper_mock.expect :new, scraper_instance_mock, [page]

          Scrapers.stub_const(:RequestBody, request_mock) do
            klass_name = PROVIDER_MAP[provider].to_s.split("::").last.to_sym
            Scrapers.stub_const(klass_name, scraper_mock) do
              result = Scrapers::Scrape.call(provider, page)

              assert_equal expected_result, result
              assert_mock request_mock
              assert_mock scraper_instance_mock
              assert_mock scraper_mock
            end
          end
        end

        test "raises error when not jobs" do
          page = rand(20)
          url = "fake url"
          headers = {"header" => "fake"}
          body = "fake body"
          result = []

          request_mock = Minitest::Mock.new
          request_mock.expect :call, body, [url, headers]

          scraper_instance_mock = Minitest::Mock.new
          # first call for request body and second for raise error
          scraper_instance_mock.expect :url, url
          scraper_instance_mock.expect :url, url
          scraper_instance_mock.expect :headers, headers
          scraper_instance_mock.expect :call, result, [body]

          scraper_mock = Minitest::Mock.new
          scraper_mock.expect :new, scraper_instance_mock, [page]

          Scrapers.stub_const(:RequestBody, request_mock) do
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
end
