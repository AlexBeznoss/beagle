class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(provider, page = nil)
    jobs = Scrapers::Scrape.call(provider, page)
    existing_jobs = JobPost.where(provider:, pid: jobs.pluck(:pid)).pluck(:pid)

    jobs
      .reject { |j| existing_jobs.include?(j[:pid]) }
      .each { |job| create_job_post!(provider, job) }
  rescue Scrapers::RequestBody::RequestError => e
    return if provider == "remoteok" && e.status == 504
    return if provider == "weworkremotely" && e.status == 503

    raise e
  end

  private

  def create_job_post!(provider, job)
    job_post = JobPost.create!(job.merge(provider:))
    JobPosts::UploadImgJob.perform_later(job_post.id) if job_post.img_url.present?
  end
end
