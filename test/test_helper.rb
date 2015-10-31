$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
if ENV['TESTLOCAL']
  require 'simplecov'
  SimpleCov.start
else
  require 'coveralls'
  Coveralls.wear!
end

require 'aliyun/oss'

require 'minitest/autorun'
require 'mocha/mini_test'
require 'webmock/minitest'
require 'timecop'
require 'pry'

def stub_get_request(path, file_path, options = {})
  stub_client_request(:get, path, file_path, options)
end

def stub_put_request(path, file_path, options = {})
  stub_client_request(:put, path, file_path, options)
end

def stub_post_request(path, file_path, options = {})
  stub_client_request(:post, path, file_path, options)
end

def stub_delete_request(path, file_path, options = {})
  stub_client_request(:delete, path, file_path, options)
end

def stub_options_request(path, file_path, options = {})
  stub_client_request(:options, path, file_path, options)
end

def stub_head_request(path, file_path, options = {})
  stub_client_request(:head, path, file_path, options)
end

def stub_client_request(verb, path, file_path, options = {})
  body = file_path.empty? ? file_path : File.new(fixture_path(file_path))
  headers = options.fetch(:response_headers, {})
            .merge(content_type: 'application/xml')

  stub_request(verb, path)
    .with(query: options.fetch(:query, {}))
    .to_return(
      status: options[:status] || 200,
      headers: headers,
      body: body
    )
end

def fixture_path(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end
