$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "minitest"
require 'faraday'
require 'vcr'
require 'minitest-vcr'
require 'webmock'

require "minitest/autorun"
require "minispec-metadata"
require 'minitest/rg'
require 'json_expressions/minitest'

require "webmock"
require "mocha/setup"
require 'faraday_middleware'
require "faraday"
require "vcr"

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock
end
