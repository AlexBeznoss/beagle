class ScrapeJob
  include Sidekiq::Job

  def perform(provider, page = nil)
    jobs = Scrapers::Scrape.call(provider, page)
    pids = jobs.map(&:pid)
    existing_jobs = JobPost.where(provider:, pid: pids).pluck(:pid)

    jobs.reject { |j| existing_jobs.include?(j.pid) }.each do |job|
      JobPost.create!(job.to_h)
    end
  end
end
