# -*- encoding: utf-8 -*-
require File.expand_path('../lib/nilac/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Adhithya Rajasekaran"]
  gem.email         = ["adhithyan15@gmail.com"]
  gem.description   = %q{Nilac is the official compiler of Nila language}
  gem.summary       = %q{Nilac compiles Nila files into line for line Javascript.}
  gem.homepage      = "http://adhithyan15.github.com/nila"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "nilac"
  gem.require_paths = ["lib"]
  gem.version       = Nilac::VERSION
  gem.add_dependency("shark","~> 0.0.0.5.4")
  gem.add_dependency("slop")
end
