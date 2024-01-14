class EnqueueScrapersJob < ApplicationJob
  queue_as :default

  after_perform do
    Rails.application
      .credentials
      .dig(:honeybadger, :checkins, :start_scraping)
      .then { |key| Honeybadger.check_in(key) }
  end

  def perform
    ScrapeJob.perform_later("gorails")
    ScrapeJob.perform_later("remoteok")
    ScrapeJob.perform_later("startupjobs")
    ScrapeJob.perform_later("weworkremotely")
    # NOTE: uncomment when rubyjobboard get up
    # ScrapeJob.perform_later("rubyjobboard")
    ScrapeJob.perform_later("rubyonremote")
  end
end
