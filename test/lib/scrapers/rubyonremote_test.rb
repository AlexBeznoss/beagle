require "test_helper"

class Scrapers::RubyonremoteTest < ActiveSupport::TestCase
  def listing
    File.read(file_fixture("rubyonremote_current_listing.html"))
  end

  def detail
    File.read(file_fixture("rubyonremote_current_detail.html"))
  end

  def scraper_for(pages, cache: ActiveSupport::Cache::MemoryStore.new)
    @requests = []
    client = Object.new
    requests = @requests
    client.define_singleton_method(:call) do |url|
      requests << url
      pages.fetch(url)
    end
    Scrapers::Rubyonremote.new(client: client, cache: cache)
  end

  def first_page
    doc = Nokogiri::HTML5(listing)
    doc.css("a[href]").to_a.rfind { |n| n.at_css("h2") }.remove
    doc.to_html
  end

  def pages
    {Scrapers::Rubyonremote::BASE_URL => first_page,
     "https://rubyonremote.com/jobs/62908-full-stack-engineer-i-at-better-stack" => detail}
  end

  test "preserves slugs and fields and expands truncated visible geographic restrictions" do
    scraper = scraper_for(pages)
    jobs = scraper.call
    assert_equal 2, jobs.size
    assert_equal "75673-software-developer-ruby-on-rails-at-e-j-electric-installation-co", jobs.first[:pid]
    assert_equal "E-J Electric Installation Co", jobs.first[:company]
    assert_equal "US", jobs.first[:location]
    assert_match %r{https://cdn.rubyonremote.com/}, jobs.first[:img_url]
    assert_equal "US, Canada, UK, EU, Europe, North America", jobs.last[:location]
    assert_equal 2, @requests.size
  end

  test "fetches every advertised page including gaps and deduplicates featured jobs" do
    data = pages
    data[Scrapers::Rubyonremote::BASE_URL] += '<a href="/remote-ruby-jobs/?page=3">3</a>'
    data["#{Scrapers::Rubyonremote::BASE_URL}?page=2"] = first_page
    data["#{Scrapers::Rubyonremote::BASE_URL}?page=3"] = first_page.sub("75673-software", "75674-software")
    jobs = scraper_for(data).call
    assert_equal 3, jobs.size
    assert_includes @requests, "#{Scrapers::Rubyonremote::BASE_URL}?page=2"
    assert_includes @requests, "#{Scrapers::Rubyonremote::BASE_URL}?page=3"
    assert_equal 1, @requests.count { |url| url.include?("/jobs/") }
  end

  test "refreshes cached location when the listing summary changes" do
    cache = ActiveSupport::Cache::MemoryStore.new
    scraper_for(pages, cache: cache).call
    scraper_for(pages, cache: cache).call
    assert_equal 1, @requests.size
    changed = pages.transform_values { |body| body.gsub("+1 more", "+2 more") }
    scraper_for(changed, cache: cache).call
    assert_equal 2, @requests.size
  end

  test "rejects challenge and empty or changed listing rather than partial success" do
    ["<title>Just a moment...</title>", "<h1>Remote Ruby Jobs</h1>", first_page.sub("Remote Ruby Jobs", "Something else")].each do |body|
      assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for({Scrapers::Rubyonremote::BASE_URL => body}).call }
    end
  end

  test "rejects changed company fields" do
    body = first_page.gsub("E-J Electric Installation Co", "")
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(pages.merge(Scrapers::Rubyonremote::BASE_URL => body)).call }
  end

  test "rejects unsafe pagination and backward next links and page limits" do
    ["https://evil.example/remote-ruby-jobs/?page=2", "/other/?page=2", "/remote-ruby-jobs/?page=51", "/remote-ruby-jobs/?page=0", "/remote-ruby-jobs/?page=1"].each do |href|
      body = first_page + "<a rel='next' href='#{href}'>Next</a>"
      assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(pages.merge(Scrapers::Rubyonremote::BASE_URL => body)).call }
    end
  end

  test "does not return collected jobs after a later page failure" do
    data = pages.merge(Scrapers::Rubyonremote::BASE_URL => first_page + '<a href="?page=2">2</a>', "#{Scrapers::Rubyonremote::BASE_URL}?page=2" => "<title>Just a moment...</title>")
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(data).call }
  end

  test "rejects detail title mismatch" do
    data = pages.transform_values { |body| body.sub("schema-job-title", "changed-title") }
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(data).call }
  end
  test "rejects location marker changes instead of losing restrictions" do
    body = first_page.gsub(Scrapers::Rubyonremote::LOCATION_SVG_PATH, "changed-icon")
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(pages.merge(Scrapers::Rubyonremote::BASE_URL => body)).call }
  end

  test "discovers additional pages advertised by later pages" do
    data = pages.merge(Scrapers::Rubyonremote::BASE_URL => first_page + '<a href="?page=2">2</a>', "#{Scrapers::Rubyonremote::BASE_URL}?page=2" => first_page + '<a href="?page=3">3</a>', "#{Scrapers::Rubyonremote::BASE_URL}?page=3" => first_page)
    assert_equal 2, scraper_for(data).call.size
    assert_includes @requests, "#{Scrapers::Rubyonremote::BASE_URL}?page=3"
  end
  test "rejects a missing pagination control when total requires more pages" do
    data = pages.merge(Scrapers::Rubyonremote::BASE_URL => first_page + "<h3>153 results total</h3>")
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(data).call }
  end
  test "limits concurrent fetches to four" do
    body = first_page.gsub("+1 more", "North America")
    client = Object.new
    lock = Mutex.new
    active = 0
    peak = 0
    client.define_singleton_method(:call) do |url|
      lock.synchronize {
        active += 1
        peak = [peak, active].max
      }
      sleep 0.01
      (url == Scrapers::Rubyonremote::BASE_URL) ? body + '<a href="?page=6">6</a>' : body
    ensure
      lock.synchronize { active -= 1 }
    end
    assert_equal 2, Scrapers::Rubyonremote.new(client: client).call.size
    assert_equal 4, peak
  end
  test "rejects partial crawl arguments before making requests" do
    client = Object.new
    client.define_singleton_method(:call) { |url| flunk "Unexpected paid request" }
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { Scrapers::Rubyonremote.new(2, client: client).call }
  end
  test "rejects an incomplete catalog even when pagination controls exist" do
    data = pages.merge(Scrapers::Rubyonremote::BASE_URL => first_page + '<h3>153 results total</h3><a href="?page=2">2</a>', "#{Scrapers::Rubyonremote::BASE_URL}?page=2" => first_page)
    error = assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(data).call }
    assert_match "2 of 153 jobs", error.message
  end

  test "uses the largest total seen and allows extra new jobs" do
    data = pages.merge(Scrapers::Rubyonremote::BASE_URL => first_page + '<h3>1 results total</h3><a href="?page=2">2</a>', "#{Scrapers::Rubyonremote::BASE_URL}?page=2" => first_page + "<h3>2 results total</h3>")
    assert_equal 2, scraper_for(data).call.size
    data["#{Scrapers::Rubyonremote::BASE_URL}?page=2"] = first_page + "<h3>3 results total</h3>"
    assert_raises(Scrapers::Rubyonremote::InvalidPage) { scraper_for(data).call }
  end
end
