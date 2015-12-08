# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aliyun/oss/version'

Gem::Specification.new do |spec|
  spec.name          = 'aliyun-oss-sdk'
  spec.version       = Aliyun::Oss::VERSION
  spec.authors       = ['Newell Zhu']
  spec.email         = ['zlx.star@gmail.com']

  spec.summary       = 'Aliyun OSS Ruby SDK'
  spec.description   = 'Aliyun OSS Ruby SDK'
  spec.homepage      = 'https://github.com/zlx/aliyun-oss-sdk'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|demo)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'httparty'
  spec.add_dependency 'addressable'
  spec.add_dependency 'gyoku'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'timecop'
  spec.add_development_dependency 'rubocop'
end
