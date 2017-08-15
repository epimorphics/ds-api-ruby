$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'yajl'

require 'bundler'
Bundler.require(:default, :development, :test)

require 'minitest'
require 'minitest/autorun'
require 'minitest/rg'
require 'faraday'
require 'faraday_middleware'
require 'json_expressions/minitest'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end
