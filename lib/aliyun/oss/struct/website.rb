module Aliyun
  module Oss
    module Struct
      class Website < Base
        # A suffix that is appended to a request that is for a directory on the website endpoint (e.g. if the suffix is index.html and you make a request to samplebucket/images/ the data that is returned will be for the object with the key name images/index.html) The suffix must not be empty and must not include a slash character.
        attr_accessor :suffix

        # The object key name to use when a 4XX class error occurs
        attr_accessor :error_key
      end
    end
  end
end
