$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'
SimpleCov.start

require 'aliyun/oss'

require 'minitest/autorun'
require 'mocha/mini_test'
require 'webmock/minitest'
require 'timecop'
