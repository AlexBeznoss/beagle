source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.2"

gem "rails", "~> 7.0.4"
gem "propshaft"
gem "pg"
gem "puma", "< 7"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "redis", "~> 5.0"
gem "nokogiri"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "bootsnap", require: false
gem "faraday"
gem "sidekiq"
gem "sidekiq-cron"
gem "sidekiq-iteration"
gem "pagy"
gem "honeybadger", "~> 5.0"
gem "health-monitor-rails"
gem "aws-sdk-s3", require: false
gem "down"
gem "meilisearch-rails"
gem "skylight"
gem "ferrum"
gem "phlex-rails"
gem "clerk-sdk-ruby", require: "clerk"
gem "baby_squeel"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri mingw x64_mingw]
  gem "standard", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-capybara", require: false
  gem "bundler-audit"
  gem "ruby_audit"
  gem "dotenv-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "rails_real_favicon"
  gem "brakeman"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "cuprite"
  gem "webmock"
  gem "minitest-rails"
  gem "minitest-stub-const"
  gem "factory_bot_rails"
  gem "phlex-testing-nokogiri"
end
