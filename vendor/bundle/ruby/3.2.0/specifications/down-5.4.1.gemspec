# -*- encoding: utf-8 -*-
# stub: down 5.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "down".freeze
  s.version = "5.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Janko Marohni\u0107".freeze]
  s.date = "2023-05-20"
  s.email = ["janko.marohnic@gmail.com".freeze]
  s.homepage = "https://github.com/janko/down".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3".freeze)
  s.rubygems_version = "3.4.10".freeze
  s.summary = "Robust streaming downloads using Net::HTTP, HTTP.rb or wget.".freeze

  s.installed_by_version = "3.4.10" if s.respond_to? :installed_by_version

  s.specification_version = 4

  s.add_runtime_dependency(%q<addressable>.freeze, ["~> 2.8"])
  s.add_development_dependency(%q<minitest>.freeze, ["~> 5.8"])
  s.add_development_dependency(%q<mocha>.freeze, ["~> 1.5"])
  s.add_development_dependency(%q<rake>.freeze, [">= 0"])
  s.add_development_dependency(%q<httpx>.freeze, ["~> 0.22", ">= 0.22.2"])
  s.add_development_dependency(%q<http>.freeze, ["~> 5.0"])
  s.add_development_dependency(%q<posix-spawn>.freeze, [">= 0"])
  s.add_development_dependency(%q<http_parser.rb>.freeze, [">= 0"])
  s.add_development_dependency(%q<warning>.freeze, [">= 0"])
end
