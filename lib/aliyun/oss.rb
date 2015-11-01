require 'aliyun/oss/version'
require 'aliyun/oss/client'
require 'aliyun/oss/struct'
require 'aliyun/oss/error'

module Aliyun
  module Oss
    autoload :Utils,            'aliyun/oss/utils'
    autoload :Http,             'aliyun/oss/http'
    autoload :Authorization,    'aliyun/oss/authorization'
    autoload :XmlGenerator,     'aliyun/oss/xml_generator'
  end
end
