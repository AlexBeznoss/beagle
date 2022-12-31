require "test_helper"

class ScrapeJobTest < ActiveSupport::TestCase
  describe "#perform" do
    test "creates job posts from scraped jobs" do
      provider = "gorails"
      page = 123
      today = Time.zone.now.to_date
      job1 = Scrapers::Scrape::JobData.new(
        provider:,
        pid: "pid1",
        name: "name1",
        url: "url1",
        company: "company1",
        img_url: "url1",
        location: "location1",
        posted_at: today
      )
      job2 = Scrapers::Scrape::JobData.new(
        provider:,
        pid: "pid2",
        name: "name2",
        url: "url2",
        company: "company2",
        img_url: "url2",
        location: "location2",
        posted_at: today
      )
      jobs = [job1, job2]
      scrape_mock = Minitest::Mock.new
      scrape_mock.expect :call, jobs, [provider, page]

      Scrapers.stub_const(:Scrape, scrape_mock) do
        assert_equal 0, JobPost.count

        ScrapeJob.new.perform(provider, page)

        assert_equal 2, JobPost.count
      end
    end

    test "creates jobs with all attributes from job_data" do
      provider = "gorails"
      page = 13
      yesterday = Time.zone.yesterday.to_date
      job = Scrapers::Scrape::JobData.new(
        provider:,
        pid: "pid",
        name: "name",
        url: "url",
        company: "company",
        img_url: "img_url",
        location: "location",
        posted_at: yesterday
      )
      scrape_mock = Minitest::Mock.new
      scrape_mock.expect :call, [job], [provider, page]

      Scrapers.stub_const(:Scrape, scrape_mock) do
        ScrapeJob.new.perform(provider, page)

        job_post = JobPost.last
        assert_equal provider, job_post.provider
        assert_equal "pid", job_post.pid
        assert_equal "name", job_post.name
        assert_equal "url", job_post.url
        assert_equal "company", job_post.company
        assert_equal "img_url", job_post.img_url
        assert_equal "location", job_post.location
        assert_equal Date.yesterday, job_post.posted_at
      end
    end

    describe "when parsed jobs already exist" do
      test "not creates new ones" do
        provider = "gorails"
        page = 123
        today = Time.zone.now.to_date
        job1 = Scrapers::Scrape::JobData.new(
          provider:,
          pid: "pid1",
          name: "name1",
          url: "url1",
          company: "company1",
          img_url: "url1",
          location: "location1",
          posted_at: today
        )
        job2 = Scrapers::Scrape::JobData.new(
          provider:,
          pid: "pid2",
          name: "name2",
          url: "url2",
          company: "company2",
          img_url: "url2",
          location: "location2",
          posted_at: today
        )
        jobs = [job1, job2]
        scrape_mock = Minitest::Mock.new
        scrape_mock.expect :call, jobs, [provider, page]
        FactoryBot.create(:job_post, provider:, pid: "pid2")

        Scrapers.stub_const(:Scrape, scrape_mock) do
          assert_equal 1, JobPost.count

          ScrapeJob.new.perform(provider, page)

          assert_equal 2, JobPost.count
          assert_equal "pid1", JobPost.last.pid
        end
      end
    end
  end
end
