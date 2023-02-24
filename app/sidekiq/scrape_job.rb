class ScrapeJob
  include Sidekiq::Job
  sidekiq_options retry: false

  def perform(provider, page = nil)
    jobs = Scrapers::Scrape.call(provider, page)
    pids = jobs.map(&:pid)
    existing_jobs = JobPost.where(provider:, pid: pids).pluck(:pid)

    jobs.reject { |j| existing_jobs.include?(j.pid) }.each do |job|
      job_post = JobPost.create!(job.to_h)
      JobPosts::UploadImgJob.perform_async(job_post.id) if job_post.img_url.present?
    end
  rescue Scrapers::RequestBody::RequestError => e
    # ignore remoteok timeout error
    return if provider == "remoteok" && e.status == 504

    raise e
  end
end
