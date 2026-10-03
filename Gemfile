source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby file: ".ruby-version"

gem "rails", "~> 8.1.4"
gem "sqlite3", "~> 2.9"
# The published 0.4.4 release requires SQLite 1.x; upstream supports SQLite 2.
gem "litestack", git: "https://github.com/oldmoe/litestack.git", ref: "e598e1b1f0d46f45df1e2c6213ff9b136b63d9bf"
gem "propshaft"
gem "falcon"
gem "puma"
gem "foreman", require: false
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "redis", "~> 6.0"
gem "nokogiri"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "bootsnap", require: false
gem "faraday"
gem "pagy"
gem "honeybadger", "~> 6.0"
gem "health-monitor-rails"
gem "aws-sdk-s3", require: false
gem "down"
gem "ferrum"
gem "phlex-rails"
gem "ruby-clock", require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "standard", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-factory_bot", require: false
  gem "bundler-audit"
  gem "ruby_audit"
  gem "dotenv-rails"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  gem "brakeman"
  gem "dockerfile-rails"

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
end
