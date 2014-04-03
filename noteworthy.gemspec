# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'noteworthy/version'

Gem::Specification.new do |spec|
  spec.name          = "noteworthy"
  spec.version       = Noteworthy::VERSION
  spec.authors       = ["Jan Lindblom"]
  spec.email         = ["jan.lindblom@mittmedia.se"]
  spec.summary       = %q{Short summary.}
  spec.description   = %q{Longer description.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rdoc'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubygems-tasks'
  spec.add_dependency "git"
  spec.add_dependency "rake"
end
