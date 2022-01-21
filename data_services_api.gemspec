# frozen-string-literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'data_services_api/version'

Gem::Specification.new do |spec|
  spec.name          = 'data_services_api'
  spec.version       = DataServicesApi::VERSION
  spec.authors       = ['Ian Dickinson']
  spec.email         = ['ian.dickinson@epimorphics.com']
  spec.summary       = 'Ruby wrapper for Epimorphics data service API'
  spec.homepage      = 'https://github.com/epimorphics/data-API-ruby'
  spec.license       = ''
  spec.required_ruby_version = '2.7'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday_middleware' # , "~> 0.10.0"
  spec.add_runtime_dependency 'json'
  spec.add_runtime_dependency 'yajl-ruby'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'excon'
  spec.add_development_dependency 'json_expressions'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-rg'
  spec.add_development_dependency 'minitest-vcr'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'webmock'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
