require "test_helper"

class ScrapeJobTest < ActiveJob::TestCase
  test "refreshes existing fields without duplicating or unhiding jobs" do
    post = FactoryBot.create(:job_post, provider: "remoteok", pid: "41", hidden: true, name: "Old title", img_url: nil)
    data = {pid: 41, name: "Ruby Developer", url: "https://remoteok.com/remote-jobs/ruby-41", company: "New company", location: "Europe", img_url: nil}
    Scrapers::Scrape.stub(:call, [data, data]) do
      assert_no_difference("JobPost.count") { ScrapeJob.perform_now("remoteok") }
    end
    assert_equal "Ruby Developer", post.reload.name
    assert_equal "New company", post.company
    assert_equal "Europe", post.location
    assert post.hidden?
  end

  test "invalid batches roll back records and do not enqueue image jobs" do
    data = {pid: "valid", name: "Ruby Developer", url: "https://example.com/job", img_url: "https://example.com/logo.png"}
    Scrapers::Scrape.stub(:call, [data, data.merge(pid: "invalid", name: nil)]) do
      assert_no_difference("JobPost.count") do
        assert_no_enqueued_jobs(only: JobPosts::UploadImgJob) do
          assert_raises(ActiveRecord::RecordInvalid) { ScrapeJob.perform_now("gorails") }
        end
      end
    end
  end

  test "deduplicates repeated records and queues the image once after saving" do
    data = {pid: "unique", name: "Ruby Developer", url: "https://example.com/job", img_url: "https://example.com/logo.png"}
    Scrapers::Scrape.stub(:call, [data, data]) do
      assert_difference("JobPost.count", 1) do
        assert_enqueued_jobs(1, only: JobPosts::UploadImgJob) { ScrapeJob.perform_now("gorails") }
      end
      assert_no_enqueued_jobs(only: JobPosts::UploadImgJob) { ScrapeJob.perform_now("gorails") }
    end
  end

  test "a healthy empty result saves nothing" do
    Scrapers::Scrape.stub(:call, []) do
      assert_no_difference("JobPost.count") { ScrapeJob.perform_now("remoteok") }
    end
  end

  test "changed or cleared logo URLs request attachment refresh" do
    post = FactoryBot.create(:job_post, provider: "gorails", img_url: "https://example.com/old.png")
    data = {pid: post.pid, name: post.name, url: post.url, img_url: "https://example.com/new.png"}
    Scrapers::Scrape.stub(:call, [data]) do
      assert_enqueued_with(job: JobPosts::UploadImgJob, args: [post.id, {refresh: true}]) { ScrapeJob.perform_now("gorails") }
    end
    Scrapers::Scrape.stub(:call, [data.merge(img_url: nil)]) do
      assert_enqueued_with(job: JobPosts::UploadImgJob, args: [post.id, {refresh: true}]) { ScrapeJob.perform_now("gorails") }
    end
    assert_nil post.reload.img_url
  end

  describe "#perform" do
    test "creates job posts from scraped jobs" do
      provider = "gorails"
      page = 123
      job1 = {
        pid: "pid1",
        name: "name1",
        url: "url1",
        company: "company1",
        img_url: "url1",
        location: "location1"
      }
      job2 = {
        pid: "pid2",
        name: "name2",
        url: "url2",
        company: "company2",
        img_url: "url2",
        location: "location2"
      }
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
      job = {
        pid: "pid",
        name: "name",
        url: "url",
        company: "company",
        img_url: "img_url",
        location: "location"
      }
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
      end
    end

    describe "when parsed jobs already exist" do
      test "not creates new ones" do
        provider = "gorails"
        page = 123
        job1 = {
          pid: "pid1",
          name: "name1",
          url: "url1",
          company: "company1",
          img_url: "url1",
          location: "location1"
        }
        job2 = {
          pid: "pid2",
          name: "name2",
          url: "url2",
          company: "company2",
          img_url: "url2",
          location: "location2"
        }
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
