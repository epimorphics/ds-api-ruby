$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require "minitest"
require 'yajl'
require 'yajl/http_stream'
require 'webmock'

require "minitest/autorun"
require 'minitest/rg'
require 'json_expressions/minitest'

require "webmock"
require "mocha/setup"
