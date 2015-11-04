module Aliyun
  module Oss
    module Struct
      class File < Object
        def file?
          true
        end

        # Get object share link
        #
        # @param expired_in_seconds [Integer] expire after specify seconds
        #
        # @return [String]
        def share_link(expired_in_seconds)
          client.bucket_get_object_share_link(key, expired_in_seconds)
        end
      end
    end
  end
end
