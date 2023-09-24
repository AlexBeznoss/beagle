# -*- encoding: utf-8 -*-
# stub: phlex 1.8.1 ruby lib

Gem::Specification.new do |s|
  s.name = "phlex".freeze
  s.version = "1.8.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/phlex-ruby/phlex/blob/main/CHANGELOG.md", "funding_uri" => "https://github.com/sponsors/joeldrapper", "homepage_uri" => "https://www.phlex.fun", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/phlex-ruby/phlex" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Drapper".freeze]
  s.bindir = "exe".freeze
  s.date = "2023-04-20"
  s.description = "A high-performance view framework optimised for fun.".freeze
  s.email = ["joel@drapper.me".freeze]
  s.homepage = "https://www.phlex.fun".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "A fun framework for building views in Ruby.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<concurrent-ruby>.freeze, ["~> 1.2"])
  s.add_runtime_dependency(%q<erb>.freeze, [">= 4"])
  s.add_runtime_dependency(%q<zeitwerk>.freeze, ["~> 2.6"])
end
