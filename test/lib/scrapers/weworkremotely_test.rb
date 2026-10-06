require "test_helper"

class Scrapers::WeworkremotelyTest < ActiveSupport::TestCase
  def setup
    @scraper = Scrapers::Weworkremotely.new
    @body = File.read(file_fixture("weworkremotely_example.rss"))
  end

  test "unions feeds, extracts records, filters boilerplate and deduplicates canonical IDs" do
    stub_feeds(@body)
    jobs = @scraper.call
    assert_equal 2, jobs.length
    assert_equal({pid: "edfinity-senior-software-engineer-remote", name: "Senior Software Engineer, remote",
      company: "Edfinity", url: "https://weworkremotely.com/remote-jobs/edfinity-senior-software-engineer-remote",
      img_url: "https://example.com/logo.png", location: "United States"}, jobs.first)
    assert_equal "https://weworkremotely.com/remote-jobs/acme-ruby", jobs.last[:url]
    assert_equal "Canada", jobs.last[:location]
    assert_nil jobs.last[:img_url]
    jobs.each { |job| assert JobPost.new(job.except(:img_url).merge(provider: :weworkremotely)).valid? }
    Scrapers::Weworkremotely::FEED_URLS.each { |url| assert_requested :get, url, times: 1 }
  end

  test "accepts a structurally valid empty feed" do
    stub_feeds(@body.gsub(%r{<item>.*?</item>}m, ""))
    assert_empty @scraper.call
    assert @scraper.empty_results_allowed?
  end

  test "rejects challenge HTML or malformed XML rather than returning empty jobs" do
    ["<html><body>Just a moment</body></html>", "<rss><channel>"].each do |body|
      stub_feeds(body)
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { @scraper.call }
    end
  end

  test "rejects items missing identity fields or pointing away from WWR" do
    [@body.sub(/<title>Edfinity:.*?<\/title>/, ""),
      @body.sub("https://weworkremotely.com/remote-jobs/edfinity", "https://example.com/remote-jobs/edfinity")].each do |body|
      stub_feeds(body)
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { @scraper.call }
    end
  end

  test "accepts Ruby as an explicit polyglot engineering stack" do
    body = @body.gsub(%r{<item>.*?</item>}m, "")
      .sub("</channel>", "<item><title>Semaphore: Senior Product Engineer</title><link>https://weworkremotely.com/remote-jobs/semaphore-engineer</link><description>Semaphore systems include Go, Elixir, Ruby, React, and related technologies; expertise in every language is not required.</description></item></channel>")
    stub_feeds(body)
    assert_equal ["Semaphore"], @scraper.call.pluck(:company)
  end

  test "does not hide failed feed requests" do
    stub_feeds(@body)
    stub_request(:get, Scrapers::Weworkremotely::FEED_URLS.last).to_return(status: 503, body: "Unavailable")
    assert_raises(Scrapers::RequestBody::RequestError) { @scraper.call }
  end

  test "rejects malformed image URLs" do
    stub_feeds(@body.sub("https://example.com/logo.png", "javascript:alert(1)"))
    assert_raises(Scrapers::BaseScraper::InvalidResponse) { @scraper.call }
  end

  test "excludes expired listings and rejects invalid expiration dates" do
    stub_feeds(@body.sub("<region>", "<expires_at>Sat, 01 Jan 2000 00:00:00 +0000</expires_at><region>"))
    assert_equal ["Acme"], @scraper.call.pluck(:company)
    stub_feeds(@body.sub("<region>", "<expires_at>invalid</expires_at><region>"))
    assert_raises(Scrapers::BaseScraper::InvalidResponse) { @scraper.call }
  end

  private

  def stub_feeds(body)
    Scrapers::Weworkremotely::FEED_URLS.each do |url|
      stub_request(:get, url).to_return(status: 200, body: body)
    end
  end
end
