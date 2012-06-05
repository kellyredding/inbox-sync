# -*- encoding: utf-8 -*-
require File.expand_path('../lib/inbox-sync/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name        = "inbox-sync"
  gem.version     = InboxSync::VERSION
  gem.description = %q{Move messages from one inbox to another}
  gem.summary     = %q{Move messages from one inbox to another}

  gem.authors     = ["Kelly Redding"]
  gem.email       = ["kelly@kellyredding.com"]
  gem.homepage    = "http://github.com/kellyredding/inbox-sync"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert")

  gem.add_dependency("ns-options", ["~> 0.4.1"])
  gem.add_dependency("mail", ["~> 2.4"])
end
