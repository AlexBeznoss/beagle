# -*- encoding: utf-8 -*-
# stub: rails_real_favicon 0.1.1 ruby lib

Gem::Specification.new do |s|
  s.name = "rails_real_favicon".freeze
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Philippe Bernard".freeze]
  s.date = "2021-06-25"
  s.description = "Generate and install a favicon for all platforms with RealFaviconGenerator.".freeze
  s.email = ["philippe@realfavicongenerator.net".freeze]
  s.homepage = "https://github.com/RealFaviconGenerator/rails_real_favicon".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Manage the favicon of your RoR project with RealFaviconGenerator".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<rails>.freeze, [">= 0"])
  s.add_runtime_dependency(%q<json>.freeze, [">= 1.7", "< 3"])
  s.add_runtime_dependency(%q<rubyzip>.freeze, ["~> 2"])
end
