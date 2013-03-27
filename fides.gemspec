# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fides/version'

Gem::Specification.new do |spec|
  spec.name          = "fides"
  spec.version       = Fides::VERSION
  spec.authors       = ["Martin Kraft"]
  spec.email         = ["martin.kraft@gmail.com"]
  spec.description   = %q{Maintains referential integrity of Rails polymorphic associations.}
  spec.summary       = %q{Creates SQL triggers from Rails migrations to enforce the integrity of 
                        polymorphic associations at the database level.}
  spec.homepage      = "https://github.com/mkraft/fides"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
end
