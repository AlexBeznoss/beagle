require "test_helper"

class Scrapers::StartupjobsTest < ActiveSupport::TestCase
  def job(id = 123, **changes)
    {"id" => id, "title" => "Ruby Engineer", "url" => "https://startup.jobs/ruby-engineer-example-#{id}?utm_source=mcp", "workplace_type" => "remote", "company" => {"name" => "Example", "logo_url" => "https://startup.jobs/logos/1"}, "location" => {"city" => "Mexico City", "state" => "Mexico City", "country" => "Mexico"}}.merge(changes.stringify_keys)
  end

  def stub_search(query, jobs, cursor: nil, next_cursor: nil, has_more: false, sse: false, text_only: false)
    data = {jobs: jobs, has_more: has_more, next_cursor: next_cursor}
    arguments = {q: query, workplace_type: "remote", limit: 50}
    arguments[:cursor] = cursor if cursor
    stub_request(:post, Scrapers::StartupjobsClient::ENDPOINT).with do |request|
      body = JSON.parse(request.body)
      body["method"] == "tools/call" && body.dig("params", "name") == "search_jobs" && body.dig("params", "arguments") == arguments.stringify_keys
    end.to_return do |request|
      result = text_only ? {content: [{type: "text", text: JSON.generate(data)}]} : {structuredContent: data}
      body = JSON.generate(jsonrpc: "2.0", id: JSON.parse(request.body)["id"], result: result)
      {status: 200, headers: {"Content-Type" => sse ? "text/event-stream" : "application/json"}, body: sse ? "event: message\ndata: #{body}\n\n" : body}
    end
  end

  test "paginates both searches, deduplicates IDs, filters remote and preserves geographic restrictions" do
    stub_search("ruby", [job, job(124, workplace_type: "hybrid")], has_more: true, next_cursor: "124")
    stub_search("ruby", [job(125)], cursor: "124", sse: true)
    stub_search("rails", [job], text_only: true)
    records = Scrapers::Startupjobs.new.call
    assert_equal 2, records.size
    assert_equal({pid: "ruby-engineer-example-123", name: "Ruby Engineer", company: "Example", url: "https://startup.jobs/ruby-engineer-example-123", img_url: "https://startup.jobs/logos/1", location: "Remote, Mexico City, Mexico"}, records.first)
    assert records.all? { |attributes| JobPost.new(attributes.merge(provider: "startupjobs")).valid? }
  end

  test "retains country code when the source omits its display name" do
    stub_search("ruby", [job(123, location: {"country_code" => "US"})])
    stub_search("rails", [])
    assert_equal "Remote, US", Scrapers::Startupjobs.new.call.first[:location]
  end

  test "does not save a Java role that matched only its company name" do
    stub_search("ruby", [job(123, title: "Java Engineer", company: {"name" => "Ruby Systems"})])
    stub_search("rails", [])
    assert_empty Scrapers::Startupjobs.new.call
  end

  test "allows an explicit empty result" do
    stub_search("ruby", [])
    stub_search("rails", [])
    scraper = Scrapers::Startupjobs.new
    assert_empty scraper.call
    assert scraper.empty_results_allowed?
  end

  test "rejects repeated cursors" do
    stub_search("ruby", [job], has_more: true, next_cursor: "123")
    stub_search("ruby", [job], cursor: "123", has_more: true, next_cursor: "123")
    assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Startupjobs.new.call }
  end

  test "rejects a has_more page with no cursor" do
    stub_search("ruby", [job], has_more: true)
    assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Startupjobs.new.call }
  end

  test "raises on pagination cap rather than returning truncated results" do
    stub_search("ruby", [job], has_more: true, next_cursor: "123")
    Scrapers::Startupjobs.stub_const(:MAX_PAGES, 1) do
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Startupjobs.new.call }
    end
  end

  test "rejects schema changes, missing company and invalid URLs" do
    [job(123, company: nil), job(123, url: "https://evil.example/ruby-123"), job(123, workplace_type: nil), job(123, location: "Worldwide")].each do |invalid_job|
      WebMock.reset!
      stub_search("ruby", [invalid_job])
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Startupjobs.new.call }
    end
  end

  test "rejects missing page fields" do
    stub_request(:post, Scrapers::StartupjobsClient::ENDPOINT).to_return(status: 200, body: JSON.generate(jsonrpc: "2.0", id: 1, result: {structuredContent: {jobs: []}}))
    assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Startupjobs.new.call }
  end

  test "reports HTTP failures and timeouts" do
    request = stub_request(:post, Scrapers::StartupjobsClient::ENDPOINT).to_return(status: 429, body: "rate limited")
    assert_raises(Scrapers::RequestBody::RequestError) { Scrapers::Startupjobs.new.call }
    remove_request_stub(request)
    stub_request(:post, Scrapers::StartupjobsClient::ENDPOINT).to_timeout
    assert_raises(Faraday::TimeoutError, Faraday::ConnectionFailed) { Scrapers::Startupjobs.new.call }
  end

  test "rejects JSON-RPC errors, tool errors, mismatched IDs and malformed JSON" do
    [{jsonrpc: "2.0", id: 1, error: {code: -32000}}, {jsonrpc: "2.0", id: 1, result: {isError: true}}, {jsonrpc: "2.0", id: 999, result: {}}, "not json"].each do |response|
      WebMock.reset!
      stub_request(:post, Scrapers::StartupjobsClient::ENDPOINT).to_return(status: 200, body: response.is_a?(String) ? response : JSON.generate(response))
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Startupjobs.new.call }
    end
  end
end
