module Aliyun
  module Oss
    class Client
      module BucketMultiparts
        # Init a Multipart Upload Event
        #
        # @param (see #bucket_init_multipart)
        #
        # @raise [RequestError]
        #
        # @return [Aliyun::Oss::Struct::Multipart]
        #
        # @see Client#bucket_init_multipart
        def init(*args)
          result = client.bucket_init_multipart(*args).parsed_response

          multipart = Utils.dig_value(result, 'InitiateMultipartUploadResult')
          Struct::Multipart.new((multipart || {}).merge(client: client))
        end

        # List exist Multipart Upload Events of bucket
        #
        # @param (see #bucket_list_multiparts)
        #
        # @option (see #bucket_list_multiparts)
        #
        # @raise [RequestError]
        #
        # @return [Array<Aliyun::Oss::Struct::Multipart>]
        #
        # @see Client#bucket_list_multiparts
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
