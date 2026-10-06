class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(provider, page = nil)
    jobs = Scrapers::Scrape.call(provider, page)
    image_jobs = []
    JobPost.transaction do
      jobs.uniq { |job| job.fetch(:pid).to_s }.each do |job|
        job_post = JobPost.find_or_initialize_by(provider:, pid: job.fetch(:pid).to_s)
        new_record = job_post.new_record?
        job_post.assign_attributes(job)
        upload_image = new_record ? job_post.img_url.present? : job_post.img_url_changed?
        job_post.save! if job_post.new_record? || job_post.changed?
        image_jobs << [job_post.id, !new_record] if upload_image
      end
    end
    image_jobs.each do |id, refresh|
      refresh ? JobPosts::UploadImgJob.perform_later(id, refresh: true) : JobPosts::UploadImgJob.perform_later(id)
    end
  rescue Scrapers::RequestBody::RequestError => e
    return if provider == "remoteok" && e.status == 504
    return if provider == "weworkremotely" && e.status == 503

    raise e
  end
end
