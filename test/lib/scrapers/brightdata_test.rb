require "test_helper"

class Scrapers::BrightdataTest < ActiveSupport::TestCase
  URL = "https://rubyonremote.com/remote-ruby-jobs/"

  test "uses the encrypted credential and configured zone to fetch HTML" do
    body = "<html><title>Ruby jobs</title><body>Jobs</body></html>"
    stub_request(:post, Scrapers::Brightdata::ENDPOINT)
      .with(headers: {"Authorization" => "Bearer test-key", "Content-Type" => "application/json"}, body: {zone: "rubyonremote", url: URL, format: "json"}.to_json)
      .to_return(body: {status_code: 200, body: body}.to_json)
    Rails.application.credentials.stub(:brightdata, "test-key") do
      assert_equal body, Scrapers::Brightdata.new.call(URL)
    end
  end

  test "rejects missing credentials before sending a request" do
    assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Brightdata.new(api_key: nil) }
    assert_not_requested(:post, Scrapers::Brightdata::ENDPOINT)
  end

  test "rejects outer and embedded request failures without exposing credentials" do
    stub_request(:post, Scrapers::Brightdata::ENDPOINT).to_return(status: 401, body: "test-key")
    client = Scrapers::Brightdata.new(api_key: "test-key")
    error = assert_raises(Scrapers::Brightdata::RequestError) { client.call(URL) }
    assert_equal 401, error.status
    assert_not_includes error.message, "test-key"
    stub_request(:post, Scrapers::Brightdata::ENDPOINT).to_return(body: {status_code: 407, body: ""}.to_json)
    error = assert_raises(Scrapers::Brightdata::RequestError) { client.call(URL) }
    assert_equal 407, error.status
  end

  test "rejects empty malformed or challenge responses despite outer success" do
    ["not JSON", {}.to_json, {status_code: 200, body: ""}.to_json,
      {status_code: 200, body: "<title>Just a moment...</title>"}.to_json].each do |response|
      stub_request(:post, Scrapers::Brightdata::ENDPOINT).to_return(body: response)
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Brightdata.new(api_key: "test-key").call(URL) }
    end
  end

  test "does not spend requests on unrelated hosts or paths" do
    ["https://example.com/jobs/123", "https://rubyonremote.com/session", "https://user:pass@rubyonremote.com/jobs/123"].each do |url|
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Brightdata.new(api_key: "test-key").call(url) }
    end
    assert_not_requested(:post, Scrapers::Brightdata::ENDPOINT)
  end

  test "reports timeouts" do
    stub_request(:post, Scrapers::Brightdata::ENDPOINT).to_timeout
    assert_raises(Faraday::TimeoutError, Faraday::ConnectionFailed) { Scrapers::Brightdata.new(api_key: "test-key").call(URL) }
  end
end
