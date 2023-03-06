class EnqueueScrapersJob
  include Sidekiq::Job

  def perform
    CallOnceLockService.call("EnqueueScrapersJobLock") do
      ScrapeJob.perform_async("gorails")
      ScrapeJob.perform_async("remoteok")
      ScrapeJob.perform_async("startupjobs")
      ScrapeJob.perform_async("weworkremotely")
      # NOTE: uncomment when rubyjobboard get up
      # ScrapeJob.perform_async("rubyjobboard")
      (1..3).to_a.each do |page|
        ScrapeJob.perform_async("rubyonremote", page)
      end

      check_in
    end
  end

  private

  def check_in
    Rails.application
      .credentials
      .dig(:honeybadger, :checkins, :start_scraping)
      .then { |key| Honeybadger.check_in(key) }
  end
end
