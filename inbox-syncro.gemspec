# -*- encoding: utf-8 -*-
require File.expand_path('../lib/inbox-syncro/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "inbox-syncro"
  gem.version     = InboxSyncro::VERSION
  gem.description = %q{TODO: Write a gem description}
  gem.summary     = %q{TODO: Write a gem summary}

  gem.authors     = ["TODO: authors"]
  gem.email       = ["TODO: emails"]
  gem.homepage    = "http://github.com/__/inbox-syncro"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert")

  # gem.add_dependency("gem-name", ["~> 0.0"])
end
