HealthMonitor.configure do |config|
  config.cache
  config.redis
  config.sidekiq
end
