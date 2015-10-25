require "aliyun/oss/version"
require 'pry'

module Aliyun
  module Oss
    autoload :Utils,        'aliyun/oss/utils'
    autoload :Client,       'aliyun/oss/client'
    autoload :Http,         'aliyun/oss/http'
    autoload :XmlBuilder,   'aliyun/oss/xml_builder'
    autoload :Authorization,'aliyun/oss/authorization'

    module Rule
      autoload :LifeCycle,      'aliyun/oss/rule/lifecycle'
      autoload :Cors,           'aliyun/oss/rule/cors'
    end

    module Multipart
      autoload :Part,           'aliyun/oss/multipart/part'
    end

    class << self
      def new *args
        Base.new(*args)
      end
    end

    class Base
      attr_reader :client

      def initialize(access_key, secret_key, options = {})
        @client = Client.new(access_key, secret_key, options)
      end

      def list_buckets *args
        @client.list_buckets *args
      end
    end
  end
end
