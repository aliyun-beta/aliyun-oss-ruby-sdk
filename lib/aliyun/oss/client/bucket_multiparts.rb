module Aliyun
  module Oss
    class Client
      module BucketMultiparts
        # Init a Multipart Upload Event
        #
        # @see Api::BucketMultiparts#bucket_init_multipart
        # @example (see Api::BucketMultiparts#bucket_init_multipart)
        # @param (see Api::BucketMultiparts#bucket_init_multipart)
        # @raise (see Api::BucketMultiparts#bucket_init_multipart)
        #
        # @return [Struct::Multipart]
        def init(*args)
          result = client.bucket_init_multipart(*args).parsed_response

          multipart = Utils.dig_value(result, 'InitiateMultipartUploadResult')
          Struct::Multipart.new((multipart || {}).merge(client: client))
        end

        # List exist Multipart Upload Events of bucket
        #
        # @see Api::BucketMultiparts#bucket_list_multiparts
        # @example (see Api::BucketMultiparts#bucket_list_multiparts)
        # @param (see Api::BucketMultiparts#bucket_list_multiparts)
        # @raise (see Api::BucketMultiparts#bucket_list_multiparts)
        #
        # @return [Array<Aliyun::Oss::Struct::Multipart>]
        def list(*args)
          result = client.bucket_list_multiparts(*args).parsed_response

          multipart_keys = %w(ListMultipartUploadsResult Upload)
          Utils.wrap(Utils.dig_value(result, *multipart_keys)).map do |multipart|
            Struct::Multipart.new(multipart.merge(client: client))
          end
        end
      end
    end
  end
end
