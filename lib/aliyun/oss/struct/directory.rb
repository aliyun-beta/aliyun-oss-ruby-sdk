module Aliyun
  module Oss
    module Struct
      class Directory < Object
        # prefix in CommonPrefixes is key of Directory object
        alias_method :prefix=, :key=

        # List objects under directory
        #
        # @see Api::BucketObjects#bucket_list_objects
        # @example (see Api::BucketObjects#bucket_list_objects)
        # @param (see Api::BucketObjects#bucket_list_objects)
        # @raise (see Api::BucketObjects#bucket_list_objects)
        #
        # @return [Array<Aliyun::Oss::Struct::Object>]
        def list(options = {})
          Utils.stringify_keys!(options)
          client.bucket_objects.list(options.merge('prefix' => key))
        end

        def file?
          false
        end
      end
    end
  end
end
