# -*- encoding: utf-8 -*-
# stub: sidekiq-iteration 0.3.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sidekiq-iteration".freeze
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/fatkodima/sidekiq-iteration/blob/master/CHANGELOG.md", "homepage_uri" => "https://github.com/fatkodima/sidekiq-iteration", "source_code_uri" => "https://github.com/fatkodima/sidekiq-iteration" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["fatkodima".freeze, "Shopify".freeze]
  s.date = "2023-05-20"
  s.email = ["fatkodima123@gmail.com".freeze]
  s.homepage = "https://github.com/fatkodima/sidekiq-iteration".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7.0".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Makes your long-running sidekiq jobs interruptible and resumable.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<sidekiq>.freeze, [">= 6.0"])
end
