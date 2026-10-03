require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Beagle
  class Application < Rails::Application
    config.autoload_paths << "#{root}/app/views"
    config.autoload_paths << "#{root}/app/views/layouts"
    config.autoload_paths << "#{root}/app/views/components"
    config.eager_load_paths.concat(config.autoload_paths)
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.active_job.queue_adapter = :litejob
    # Company logos are displayed directly without image transformations.
    config.active_storage.variant_processor = :disabled
    config.eager_load_paths << Rails.root.join("lib")
    config.active_support.isolation_level = :fiber
  end
end
