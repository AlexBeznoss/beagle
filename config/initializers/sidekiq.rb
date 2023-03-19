require "sidekiq"
require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    Rails.application.credentials.sidekiq.username,
    Rails.application.credentials.sidekiq.password
  ]
end

redis_url = ENV["REDIS_URL"]
Sidekiq.configure_server do |config|
  config.redis = {url: redis_url, network_timeout: 5}
  config.logger = Rails.logger
end

Sidekiq.configure_client do |config|
  config.redis = {url: redis_url, network_timeout: 5}
  config.logger = Rails.logger
end

Sidekiq.strict_args!
