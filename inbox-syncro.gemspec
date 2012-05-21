# -*- encoding: utf-8 -*-
require File.expand_path('../lib/inbox-syncro/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "inbox-syncro"
  gem.version     = InboxSyncro::VERSION
  gem.description = %q{Move messages from one inbox to another}
  gem.summary     = %q{Move messages from one inbox to another}

  gem.authors     = ["Kelly Redding"]
  gem.email       = ["kelly@kellyredding.com"]
  gem.homepage    = "http://github.com/kellyredding/inbox-syncro"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert")

  # gem.add_dependency("gem-name", ["~> 0.0"])
end
