# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deus_ex/version'

Gem::Specification.new do |spec|
  spec.name          = "deus_ex"
  spec.version       = DeusEx::VERSION
  spec.authors       = ["Ben Scofield"]
  spec.email         = ["ben.scofield@livingsocial.com"]
  spec.description   = %q{Easily manage just-in-time EC2 git repos}
  spec.summary       = %q{Easily manage just-in-time EC2 git repos}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency "fog"
end
