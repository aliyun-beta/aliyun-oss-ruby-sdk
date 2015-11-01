module Aliyun
  module Oss
    module Struct
      class Base
        def initialize(attributes = {})
          attributes.each do |key, value|
            m = "#{Utils.underscore(key)}=".to_sym
            send(m, value) if self.respond_to?(m)
          end
        end
      end
    end
  end
end

require 'aliyun/oss/struct/bucket'
require 'aliyun/oss/struct/object'
require 'aliyun/oss/struct/multipart'

require 'aliyun/oss/struct/cors'
require 'aliyun/oss/struct/lifecycle'
require 'aliyun/oss/struct/referer'
require 'aliyun/oss/struct/website'
require 'aliyun/oss/struct/logging'

require 'aliyun/oss/struct/part'
