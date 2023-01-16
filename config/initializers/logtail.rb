if ENV.fetch("LOGTAIL_SKIP_LOGS", "true") != "true" && Rails.env.production?
  http_device = Logtail::LogDevices::HTTP.new(Rails.application.credentials.logtail)
  Rails.logger = Logtail::Logger.new(http_device)
end
