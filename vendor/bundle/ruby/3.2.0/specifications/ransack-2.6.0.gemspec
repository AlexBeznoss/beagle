# -*- encoding: utf-8 -*-
# stub: ransack 2.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "ransack".freeze
  s.version = "2.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ernie Miller".freeze, "Ryan Bigg".freeze, "Jon Atack".freeze, "Sean Carroll".freeze]
  s.date = "2022-03-10"
  s.description = "Ransack is the successor to the MetaSearch gem. It improves and expands upon MetaSearch's functionality, but does not have a 100%-compatible API.".freeze
  s.email = ["ernie@erniemiller.org".freeze, "radarlistener@gmail.com".freeze, "jonnyatack@gmail.com".freeze, "sfcarroll@gmail.com".freeze]
  s.homepage = "https://github.com/activerecord-hackery/ransack".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.6".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Object-based searching for Active Record and Mongoid (currently).".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.0.4"])
  s.add_runtime_dependency(%q<activesupport>.freeze, [">= 6.0.4"])
  s.add_runtime_dependency(%q<i18n>.freeze, [">= 0"])
end
