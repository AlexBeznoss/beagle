require "sidekiq"
require "sidekiq/web"
require "sidekiq/cron/web"

Sidekiq::Web.use(Rack::Auth::Basic) do |user, password|
  [user, password] == [
    Rails.application.credentials.sidekiq.username,
    Rails.application.credentials.sidekiq.password
  ]
end

Sidekiq.strict_args!
