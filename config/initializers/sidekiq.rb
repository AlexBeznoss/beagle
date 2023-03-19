require "sidekiq"
require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    Rails.application.credentials.sidekiq.username,
    Rails.application.credentials.sidekiq.password
  ]
end

class SidekiqCustomLogFormatter < Sidekiq::Logger::Formatters::Base
  delegate :is_a?, to: :logtail_formatter

  def call(severity, time, progname, msg)
    ctx_hash = ctx.compact.map { |k, v| v.is_a?(Array) ? [k, v.join(",")] : [k, v] }.to_h
    ctx_str = ctx_hash.map { |k, v| [k, v].join("=") }.join(" ")
    message = {
      ctx: ctx_hash,
      tid: tid,
      tag: "sidekiq",
      message: [ctx_str, msg].compact_blank.join(": ")
    }

    logtail_formatter.call(severity, time, progname, message)
  end

  private

  def logtail_formatter
    @logtail_formatter ||= Logtail::Logger::PassThroughFormatter.new
  end
end

if ENV.fetch("LOGTAIL_SKIP_LOGS", "true") != "true" && Rails.env.production?
  http_device = Logtail::LogDevices::HTTP.new(Rails.application.credentials.logtail)
  logger = Logtail::Logger.new(http_device)
  logger.formatter = SidekiqCustomLogFormatter.new
end

redis_url = ENV["REDIS_URL"]
Sidekiq.configure_server do |config|
  config.redis = {url: redis_url, network_timeout: 5}
  config.logger = logger if logger
end

Sidekiq.configure_client do |config|
  config.redis = {url: redis_url, network_timeout: 5}
  config.logger = logger if logger
end

Sidekiq.strict_args!
