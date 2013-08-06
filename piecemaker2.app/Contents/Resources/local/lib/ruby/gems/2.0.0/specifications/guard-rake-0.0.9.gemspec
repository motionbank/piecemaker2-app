# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "guard-rake"
  s.version = "0.0.9"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Scott Barron"]
  s.date = "2013-04-19"
  s.description = "guard-rake automatically runs Rake tasks from your Rakefile"
  s.email = ["scott@elitists.net"]
  s.homepage = "http://github.com/rubyist/guard-rake"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Guard for running rake tasks"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<guard>, [">= 0"])
      s.add_runtime_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<guard>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<guard>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
