# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'aliyun/oss/version'

Gem::Specification.new do |spec|
  spec.name          = "aliyun-oss"
  spec.version       = Aliyun::Oss::VERSION
  spec.authors       = ["Newell Zhu"]
  spec.email         = ["zlx.star@gmail.com"]

  spec.summary       = %q{Aliyun OSS Ruby SDK}
  spec.description   = %q{Aliyun OSS Ruby SDK}
  spec.homepage      = "http://github.com/aliyun/ruby-oss-sdk"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty"
  spec.add_dependency "gyoku"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "pry-byebug"
end
