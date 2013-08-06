# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "newrelic-grape"
  s.version = "1.3.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Richard Huang"]
  s.date = "2013-06-08"
  s.description = "newrelic instrument for grape"
  s.email = ["flyerhzm@gmail.com"]
  s.homepage = "https://github.com/flyerhzm/newrelic-grape"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "newrelic instrument for grape"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<grape>, [">= 0"])
      s.add_runtime_dependency(%q<newrelic_rpm>, [">= 0"])
    else
      s.add_dependency(%q<grape>, [">= 0"])
      s.add_dependency(%q<newrelic_rpm>, [">= 0"])
    end
  else
    s.add_dependency(%q<grape>, [">= 0"])
    s.add_dependency(%q<newrelic_rpm>, [">= 0"])
  end
end
