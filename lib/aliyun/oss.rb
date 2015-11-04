require 'aliyun/oss/version'
require 'aliyun/oss/struct'
require 'aliyun/oss/error'

module Aliyun
  module Oss
    autoload :Utils,            'aliyun/oss/utils'
    autoload :Client,           'aliyun/oss/client'
    autoload :Authorization,    'aliyun/oss/authorization'
  end
end
