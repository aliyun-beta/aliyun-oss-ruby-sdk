require 'aliyun/oss/version'

module Aliyun
  module Oss
    autoload :Utils,            'aliyun/oss/utils'
    autoload :Client,           'aliyun/oss/client'
    autoload :Http,             'aliyun/oss/http'
    autoload :Authorization,    'aliyun/oss/authorization'
    autoload :XmlGenerator,     'aliyun/oss/xml_generator'

    module Rule
      autoload :LifeCycle,      'aliyun/oss/rule/lifecycle'
      autoload :Cors,           'aliyun/oss/rule/cors'
    end

    module Multipart
      autoload :Part,           'aliyun/oss/multipart/part'
    end
  end
end
