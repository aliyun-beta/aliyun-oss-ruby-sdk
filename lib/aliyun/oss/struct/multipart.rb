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
        # @param number [Integer] the part number, Range in 1~10000.
        # @param file [File, bin data] the upload data
        #
        # @raise (see #bucket_multipart_upload)
        #
        # @return [true]
        def upload(*args)
          !!client.bucket_multipart_upload(*args.unshift(upload_id, key))
        end

        # Copy exsting object to Multipart Upload Event
        #
        # @param number [Integer] the part number, Range in 1~10000.
        # @param options [Hash] options
        # @option (see #bucket_multipart_copy_upload)
        #
        # @raise (see #bucket_multipart_copy_upload)
        #
        # @return [true]
        #
        # @see Client#bucket_list_parts
        def copy(*args)
          !!client.bucket_multipart_copy_upload(*args.unshift(upload_id, key))
        end

        # List uploaded parts for the Multipart Upload Event
        #
        # @param options [Hash] options
        # @option (see #bucket_list_parts)
        #
        # @raise (see #bucket_list_parts)
        #
        # @return [Array<Aliyun::Oss::Struct::Part>]
        #
        # @see Client#bucket_list_parts
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
        # @param parts [Array<Multipart:Part>] parts
        #
        # @raise (see #bucket_complete_multipart)
        #
        # @return [Struct::Object]
        #
        # @see Client#bucket_complete_multipart
        def complete(parts = [])
          resp = client.bucket_complete_multipart(upload_id, key, parts)
          keys = %w(CompleteMultipartUploadResult)
          Struct::Object.new(
            Utils.dig_value(resp.parsed_response, *keys).merge(client: client)
          )
        end

        # Abort Multipart Upload Event
        #
        # @raise (see #bucket_abort_multipart)
        #
        # @return [true]
        #
        # @see Client#bucket_abort_multipart
        def abort
          !!client.bucket_abort_multipart(upload_id, key)
        end
      end
    end
  end
end
