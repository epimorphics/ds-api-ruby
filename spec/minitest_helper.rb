$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'yajl'
require 'minitest'
require 'minitest/autorun'
require 'minitest/rg'
require 'json_expressions/minitest'

require 'bundler'
Bundler.require(:default, :development, :test)

require 'faraday'
require 'faraday_middleware'
require 'byebug'

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end
