# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'data_services_api/version'

Gem::Specification.new do |spec|
  spec.name          = "data-services-api"
  spec.version       = DataServicesApi::VERSION
  spec.authors       = ["Ian Dickinson"]
  spec.email         = ["ian@epimorphics.com"]
  spec.summary       = %q{Ruby API for Epimorphics data service API}
  spec.homepage      = "https://github.com/epimorphics/data-API-ruby"
  spec.license       = ""

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-rg"
  spec.add_development_dependency "faraday_middleware", "< 0.9.0"
  spec.add_development_dependency "json", "~> 1.8.1"
  spec.add_development_dependency "webmock", "< 1.16"
  spec.add_development_dependency "mocha", "~> 1.0.0"
  spec.add_development_dependency "excon", ">= 0.27.5"
end
