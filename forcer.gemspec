# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'forcer/version'

Gem::Specification.new do |spec|
  spec.name          = "forcer"
  spec.version       = Forcer::VERSION
  spec.authors       = ["gaziz tazhenov"]
  spec.email         = ["gaziztazhenov@gmail.com"]

  spec.summary       = %q{"facilitates change management for dev teams who use force.com and git"}
  spec.description   = %q{"command line tool written in ruby that performs metadata deployment, list of components in salesforce org"}
  spec.homepage      = "https://github.com/gazazello/forcer"
  spec.licenses      = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.7.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.required_ruby_version = ">=2.2.0"
end
