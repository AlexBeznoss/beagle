# -*- encoding: utf-8 -*-
# stub: phlex-testing-nokogiri 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "phlex-testing-nokogiri".freeze
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "changelog_uri" => "https://github.com/joeldrapper/phlex-testing-nokogiri/releases", "funding_uri" => "https://github.com/sponsors/joeldrapper", "homepage_uri" => "https://github.com/joeldrapper/phlex-testing-nokogiri", "rubygems_mfa_required" => "true", "source_code_uri" => "https://github.com/joeldrapper/phlex-testing-nokogiri" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Joel Drapper".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-11-24"
  s.description = "Nokogiri test helpers for Phlex".freeze
  s.email = ["joel@drapper.me".freeze]
  s.homepage = "https://github.com/joeldrapper/phlex-testing-nokogiri".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.7".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Nokogiri test helpers for Phlex".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<nokogiri>.freeze, ["~> 1.13"])
  s.add_runtime_dependency(%q<phlex>.freeze, [">= 0.5"])
end
