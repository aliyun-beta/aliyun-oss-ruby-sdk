module Aliyun
  module Oss
    module Struct
      class Multipart < Base
        # UUID for the Multipart Upload Event
        attr_accessor :upload_id

        # Object name of the Multipart Upload Event
        attr_accessor :key

        # Bucket name of the Multipart Upload Event
        attr_accessor :bucket

        # Initiation time of the Multipart Upload Event
        attr_accessor :initiated

        # reference to client
        attr_accessor :client

        def initiated=(initiated)
          @initiated = Time.parse(initiated)
        end

        # Upload part to Multipart Upload Event
        #
        # @see Api::BucketMultiparts#bucket_multipart_upload
        # @example (see Api::BucketMultiparts#bucket_multipart_upload)
        # @raise (see Api::BucketMultiparts#bucket_multipart_upload)
        #
        # @param number [Integer] the part number, Range in 1~10000.
        # @param file [File, bin data] the upload data
        #
        # @return [HTTParty::Response::Headers]
        def upload(*args)
          client.bucket_multipart_upload(*args.unshift(upload_id, key)).headers
        end

        # Copy exsting object to Multipart Upload Event
        #
        # @param number [Integer] the part number, Range in 1~10000.
        # @param options [Hash] options
        #
        # @see Api::BucketMultiparts#bucket_multipart_copy_upload
        # @example (see Api::BucketMultiparts#bucket_multipart_copy_upload)
        # @raise (see Api::BucketMultiparts#bucket_multipart_copy_upload)
        #
        # @return [true]
        def copy(*args)
          !!client.bucket_multipart_copy_upload(*args.unshift(upload_id, key))
        end

        # List uploaded parts for the Multipart Upload Event
        #
        # @param options [Hash] options
        #
        # @see Api::BucketMultiparts#bucket_list_parts
        # @example (see Api::BucketMultiparts#bucket_list_parts)
        # @raise (see Api::BucketMultiparts#bucket_list_parts)
        #
        # @return [Array<Aliyun::Oss::Struct::Part>]
        def list_parts(options = {})
          result = client.bucket_list_parts(upload_id, key, options)
                   .parsed_response

          parts_keys = %w(ListPartsResult Part)
          Utils.wrap(Utils.dig_value(result, *parts_keys)).map do |part|
            Struct::Part.new(part)
          end
        end

        # Complete Multipart Upload Event
        #
        # @param parts [Array<Aliyun::Oss::Multipart:Part>] parts
        #
        # @see Api::BucketMultiparts#bucket_complete_multipart
        # @example (see Api::BucketMultiparts#bucket_complete_multipart)
        # @raise (see Api::BucketMultiparts#bucket_complete_multipart)
        #
        # @return [Struct::Object]
        def complete(parts = [])
          resp = client.bucket_complete_multipart(upload_id, key, parts)
          keys = %w(CompleteMultipartUploadResult)
          Struct::Object.new(
            Utils.dig_value(resp.parsed_response, *keys).merge(client: client)
          )
        end

        # Abort Multipart Upload Event
        #
        # @see Api::BucketMultiparts#bucket_abort_multipart
        # @note (see Api::BucketMultiparts#bucket_abort_multipart)
        # @example (see Api::BucketMultiparts#bucket_abort_multipart)
        # @raise (see Api::BucketMultiparts#bucket_abort_multipart)
        #
        # @return [true]
        def abort
          !!client.bucket_abort_multipart(upload_id, key)
        end
      end
    end
  end
end
