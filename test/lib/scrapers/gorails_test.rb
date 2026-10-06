require "test_helper"

class Scrapers::GorailsTest < ActiveSupport::TestCase
  def scrape(body)
    scraper = Scrapers::Gorails.new
    scraper.define_singleton_method(:request_body) { body }
    scraper.call
  end

  def feed(fields = "")
    "<jobs><job><title>Rails developer</title><company_name>Example &amp; Co</company_name>" \
      "<url>https://jobs.gorails.com/jobs/existing-slug</url>#{fields}</job></jobs>"
  end

  test "requests the public XML feed and allows recognized empty results" do
    scraper = Scrapers::Gorails.new
    assert_equal "https://jobs.gorails.com/jobs.xml", scraper.url
    assert_equal({"Accept" => "application/xml"}, scraper.headers)
    assert scraper.empty_results_allowed?
    assert_equal [], scrape("<?xml version=\"1.0\"?><jobs />")
  end

  test "extracts captured current feed with historical slug identity and restrictions" do
    travel_to Time.utc(2026, 10, 6) do
      jobs = scrape(File.read(file_fixture("gorails_current.xml")))
      assert_equal 1, jobs.length
      assert_equal "software-developer-ruby-on-rails-ec231228", jobs.first[:pid]
      assert_equal "Software Developer, Ruby on Rails", jobs.first[:name]
      assert_equal "E-J Electric Installation Co.", jobs.first[:company]
      assert_equal "North America", jobs.first[:location]
      assert_equal "https://cdn.jobboardly.com/8wrk2q3jhyoe1lo1a2xmehqjt8eo", jobs.first[:img_url]
      assert JobPost.new(jobs.first.merge(provider: "gorails")).valid?
    end
  end

  test "joins location limits and falls back to physical location then remote type" do
    job = scrape(feed("<location_limits><location>Europe</location><location>North America</location></location_limits><location>London</location>")).first
    assert_equal "Europe, North America", job[:location]
    assert_equal "existing-slug", job[:pid]
    assert_equal "Example & Co", job[:company]
    assert_nil job[:img_url]
    assert_equal "London", scrape(feed("<location>London</location><location_type>onsite</location_type>")).first[:location]
    assert_equal "remote", scrape(feed("<location_type>remote</location_type>")).first[:location]
  end

  test "omits expired listings and rejects malformed expiry" do
    travel_to Time.utc(2026, 10, 6) do
      assert_empty scrape(feed("<expires_at>2026-10-05T12:00:00Z</expires_at>"))
      assert_equal 1, scrape(feed("<expires_at>2026-11-01T12:00:00Z</expires_at>")).size
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { scrape(feed("<expires_at>invalid</expires_at>")) }
    end
  end

  test "rejects malformed XML unexpected schemas and missing required values" do
    ["<jobs>", "<html><body>Challenge</body></html>", "<jobs><error>Denied</error></jobs>",
      '<jobs xmlns="urn:unexpected" />', '<!DOCTYPE jobs SYSTEM "file:///etc/passwd"><jobs />',
      "<jobs><job /></jobs>", feed.sub("<title>Rails developer</title>", "<title />"),
      feed.sub("https://jobs.gorails.com/jobs/existing-slug", "https://example.com/jobs/slug")].each do |body|
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { scrape(body) }
    end
  end
end
