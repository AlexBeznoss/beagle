# -*- encoding: utf-8 -*-
# stub: health-monitor-rails 11.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "health-monitor-rails".freeze
  s.version = "11.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "rubygems_mfa_required" => "true" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Leonid Beder".freeze]
  s.date = "2023-05-08"
  s.description = "Health monitoring Rails plug-in, which checks various services (db, cache, sidekiq, redis, etc.).".freeze
  s.email = ["leonid.beder@gmail.com".freeze]
  s.homepage = "https://github.com/lbeder/health-monitor-rails".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.5".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Health monitoring Rails plug-in, which checks various services (db, cache, sidekiq, redis, etc.)".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<railties>.freeze, [">= 6.1"])
end
