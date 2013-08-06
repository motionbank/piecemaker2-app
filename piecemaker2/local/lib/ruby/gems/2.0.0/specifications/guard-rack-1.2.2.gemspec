# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "guard-rack"
  s.version = "1.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Daniel Doubrovkine"]
  s.date = "2012-12-19"
  s.email = "dblock@dblock.org"
  s.extra_rdoc_files = ["LICENSE.md", "README.md"]
  s.files = ["LICENSE.md", "README.md"]
  s.homepage = "http://github.com/dblock/guard-rack"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Restart Rack when files change."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<guard>, ["~> 1.1"])
      s.add_runtime_dependency(%q<rb-fsevent>, [">= 0.3.9"])
      s.add_runtime_dependency(%q<growl>, ["~> 1.0.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<rspec>, ["~> 2.6"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6"])
      s.add_development_dependency(%q<guard-rspec>, [">= 0"])
      s.add_development_dependency(%q<fakefs>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<guard>, ["~> 1.1"])
      s.add_dependency(%q<rb-fsevent>, [">= 0.3.9"])
      s.add_dependency(%q<growl>, ["~> 1.0.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<rspec>, ["~> 2.6"])
      s.add_dependency(%q<jeweler>, ["~> 1.6"])
      s.add_dependency(%q<guard-rspec>, [">= 0"])
      s.add_dependency(%q<fakefs>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<guard>, ["~> 1.1"])
    s.add_dependency(%q<rb-fsevent>, [">= 0.3.9"])
    s.add_dependency(%q<growl>, ["~> 1.0.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<rspec>, ["~> 2.6"])
    s.add_dependency(%q<jeweler>, ["~> 1.6"])
    s.add_dependency(%q<guard-rspec>, [">= 0"])
    s.add_dependency(%q<fakefs>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
