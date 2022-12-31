class EnqueueScrapersJob
  include Sidekiq::Job

  def perform
    ScrapeJob.perform_async("gorails")
    ScrapeJob.perform_async("remoteok")
    ScrapeJob.perform_async("rubyjobboard")
    (1..3).to_a.each do |page|
      ScrapeJob.perform_async("rubyonremote", page)
    end
  end
end
