# -*- encoding: utf-8 -*-
# stub: baby_squeel 2.0.0 ruby lib

Gem::Specification.new do |s|
  s.name = "baby_squeel".freeze
  s.version = "2.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ray Zane".freeze]
  s.bindir = "exe".freeze
  s.date = "2022-08-28"
  s.description = "An expressive query DSL for Active Record 4 and 5.".freeze
  s.email = ["ray@promptworks.com".freeze]
  s.homepage = "https://github.com/rzane/baby_squeel".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.10".freeze
  s.summary = "An expressive query DSL for Active Record 4 and 5.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<activerecord>.freeze, [">= 6.0", "< 7.1"])
  s.add_runtime_dependency(%q<ransack>.freeze, ["~> 2.3"])
  s.add_development_dependency(%q<bundler>.freeze, ["~> 2"])
  s.add_development_dependency(%q<rake>.freeze, ["~> 13.0"])
  s.add_development_dependency(%q<rspec>.freeze, ["~> 3.10"])
  s.add_development_dependency(%q<sqlite3>.freeze, [">= 0"])
end
