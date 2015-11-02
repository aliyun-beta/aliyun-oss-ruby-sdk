module Aliyun
  module Oss
    module Struct
      class Directory < Object
        # prefix in CommonPrefixes is key of Directory object
        alias_method :prefix=, :key=

        # List objects under directory
        #
        # @see #bucket_list_objects
        #
        # @param (see #bucket_list_objects)
        # @option (see #bucket_list_objects)
        #
        # @raise [RequestError]
        #
        # @return [Array<Aliyun::Oss::Struct::Object>]
        def list(options = {})
          Utils.stringify_keys!(options)
          client.bucket_objects.list(options.merge('prefix' => key))
        end
      end
    end
  end
end
