if ENV["LOGTAIL_SKIP_LOGS"].blank? && Rails.env.production?
  http_device = Logtail::LogDevices::HTTP.new(Rails.application.credentials.logtail)
  Rails.logger = Logtail::Logger.new(http_device)
else
  Rails.logger = Logtail::Logger.new($stdout)
end
