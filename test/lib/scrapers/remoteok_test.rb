require "test_helper"

class Scrapers::RemoteokTest < ActiveSupport::TestCase
  test "uses the supported public API" do
    assert_equal "https://remoteok.com/api", Scrapers::Remoteok.new.url
    assert_equal({Accept: "application/json"}, Scrapers::Remoteok.new.headers)
  end

  test "extracts relevant jobs and normalizes stable IDs" do
    jobs = [
      {"legal" => "attribute Remote OK"},
      record.merge("position" => " Ruby on Rails Developer ", "company" => " Example "),
      record.merge("id" => 42, "position" => "Backend Engineer", "description" => "Our stack is Ruby, PostgreSQL and React."),
      record.merge("id" => 43, "position" => "Technical Product Manager", "tags" => ["ruby"], "description" => "Experience with Ruby products."),
      record.merge("id" => 44, "position" => "Angular Developer", "description" => "Angular experience required. NOT YOUR TECH STACK? We place Ruby developers too.")
    ]
    stub_request(:get, "https://remoteok.com/api").to_return(body: jobs.to_json)
    result = Scrapers::Remoteok.new.call
    assert_equal %w[41 42], result.pluck(:pid)
    assert_equal "Ruby on Rails Developer", result.first[:name]
    assert_equal "Example", result.first[:company]
    assert_equal "Europe", result.first[:location]
    assert_equal record["url"], result.first[:url]
    assert result.all? { |attributes| JobPost.new(attributes.merge(provider: "remoteok")).valid? }
  end

  test "deduplicates IDs and allows a healthy empty result" do
    stub_request(:get, "https://remoteok.com/api").to_return(body: [record, record].to_json)
    assert_equal 1, Scrapers::Remoteok.new.call.size
    stub_request(:get, "https://remoteok.com/api").to_return(body: [{legal: "attribution"}].to_json)
    assert_empty Scrapers::Scrape.call("remoteok")
  end

  test "an unrelated API record with a generic URL does not block valid Ruby jobs" do
    sales = record.merge("id" => 1136379, "position" => "Sales Development Representative", "url" => "https://remoteOK.com/remote-jobs/")
    stub_request(:get, "https://remoteok.com/api").to_return(body: [sales, record].to_json)
    assert_equal ["41"], Scrapers::Remoteok.new.call.pluck(:pid)
  end

  test "rejects malformed JSON and changed API envelopes" do
    ["<html>challenge</html>", {}.to_json, [nil].to_json, [{position: "Ruby Developer"}].to_json,
      [record.merge("url" => "https://example.com/unexpected")].to_json,
      [record.merge("position" => 123)].to_json, [record.merge("location" => {})].to_json].each do |body|
      stub_request(:get, "https://remoteok.com/api").to_return(body:)
      assert_raises(Scrapers::BaseScraper::InvalidResponse) { Scrapers::Remoteok.new.call }
    end
  end

  private

  def record
    {"id" => 41, "position" => "Ruby Developer", "company" => "Example", "url" => "https://remoteok.com/remote-jobs/ruby-developer-41",
     "company_logo" => "https://example.com/logo.png", "location" => " Europe "}
  end
end
