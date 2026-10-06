require "test_helper"

class Scrapers::ProviderIngestionTest < ActiveJob::TestCase
  test "GoRails live XML structure survives parsing and database persistence" do
    body = file_fixture("gorails_current.xml").read
    stub_request(:get, Scrapers::Gorails::BASE_URL).to_return(body:)
    travel_to Time.utc(2026, 10, 6) do
      ScrapeJob.perform_now("gorails")
      post = JobPost.find_by!(provider: "gorails", pid: "software-developer-ruby-on-rails-ec231228")
      assert_equal "Software Developer, Ruby on Rails", post.name
      assert_equal "E-J Electric Installation Co.", post.company
      assert_equal "North America", post.location
      assert_equal "https://jobs.gorails.com/jobs/software-developer-ruby-on-rails-ec231228", post.url
      assert_no_difference("JobPost.count") { ScrapeJob.perform_now("gorails") }
    end
  end

  test "WWR feeds save company and restrictions and exclude boilerplate jobs" do
    Scrapers::Weworkremotely::FEED_URLS.each do |url|
      stub_request(:get, url).to_return(body: file_fixture("weworkremotely_example.rss").read)
    end
    ScrapeJob.perform_now("weworkremotely")
    assert_equal 2, JobPost.where(provider: "weworkremotely").count
    post = JobPost.find_by!(provider: "weworkremotely", pid: "edfinity-senior-software-engineer-remote")
    assert_equal "Edfinity", post.company
    assert_equal "United States", post.location
    assert_equal "https://example.com/logo.png", post.img_url
    assert_nil JobPost.find_by(pid: "lemon-angular")
    assert_no_difference("JobPost.count") { ScrapeJob.perform_now("weworkremotely") }
  end

  test "RemoteOK relevant API entries save with stable IDs and refresh accurately" do
    job = {id: 41, position: "Ruby Developer", company: "Example", url: "https://remoteok.com/remote-jobs/ruby-41", location: "Europe"}
    stub_request(:get, Scrapers::Remoteok::BASE_URL).to_return(body: [{legal: "Attribution"}, job].to_json)
    ScrapeJob.perform_now("remoteok")
    post = JobPost.find_by!(provider: "remoteok", pid: "41")
    assert_equal "Ruby Developer", post.name
    assert_equal "Europe", post.location
    stub_request(:get, Scrapers::Remoteok::BASE_URL).to_return(body: [job.merge(position: "Senior Ruby Developer", location: "Canada")].to_json)
    assert_no_difference("JobPost.count") { ScrapeJob.perform_now("remoteok") }
    assert_equal "Senior Ruby Developer", post.reload.name
    assert_equal "Canada", post.location
  end

  test "StartupJobs paginated MCP data saves canonical URLs and geographic restrictions" do
    stub_request(:post, Scrapers::StartupjobsClient::ENDPOINT).to_return do |request|
      rpc = JSON.parse(request.body)
      job = {id: 123, title: "Ruby Engineer", workplace_type: "remote", url: "https://startup.jobs/ruby-engineer-example-123?utm_source=mcp", company: {name: "Example", logo_url: "https://startup.jobs/logos/1"}, location: {city: "Mexico City", country: "Mexico"}}
      {body: {jsonrpc: "2.0", id: rpc["id"], result: {structuredContent: {jobs: [job], has_more: false}}}.to_json}
    end
    ScrapeJob.perform_now("startupjobs")
    assert_equal 1, JobPost.where(provider: "startupjobs").count
    post = JobPost.find_by!(provider: "startupjobs", pid: "ruby-engineer-example-123")
    assert_equal "https://startup.jobs/ruby-engineer-example-123", post.url
    assert_equal "Remote, Mexico City, Mexico", post.location
    assert_equal "Example", post.company
    assert_no_difference("JobPost.count") { ScrapeJob.perform_now("startupjobs") }
  end
end
