require "aliyun/oss/version"

module Aliyun
  module Oss
    autoload :Bucket,       'aliyun/oss/bucket'
    autoload :Object,       'aliyun/oss/object'
    autoload :Multipart,    'aliyun/oss/multipart'
    autoload :Client,       'aliyun/oss/client'
    autoload :Http,         'aliyun/oss/http'
  end
end
