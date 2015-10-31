module Aliyun
  module Oss
    class Client
      module BucketObjects

        # List objects of bucket
        #
        # @param (see #bucket_list_objects)
        #
        # @option (see #bucket_list_objects)
        #
        # @raise [RequestError]
        #
        # @return [Array<Aliyun::Oss::Struct::Object>]
        #
        # @see Client#bucket_list_objects
        def list(*args)
          result = client.bucket_list_objects(*args).parsed_response

          object_keys = %w{ListBucketResult Contents}
          Utils.wrap(Utils.dig_value(result, *object_keys)).map do |object|
            Struct::Object.new(object.merge(client: client))
          end
        end

        # create object of bucket
        #
        # @param (see #bucket_create_object)
        #
        # @raise [RequestError]
        #
        # @return [true]
        #
        # @see Client#bucket_create_object
        def create(*args)
          !!client.bucket_create_object(*args)
        end

        # Delete object for bucket
        #
        # @param (see #bucket_delete_object)
        #
        # @raise [RequestError]
        #
        # @return [true]
        #
        # @see Client#bucket_delete_object
        def delete(*args)
          !!client.bucket_delete_object(*args)
        end

        # Delete objects for bucket
        #
        # @param (see #bucket_delete_objects)
        #
        # @raise [RequestError]
        #
        # @return [true]
        #
        # @see Client#bucket_delete_objects
        def delete_multiple(*args)
          !!client.bucket_delete_objects(*args)
        end

        # Copy from existing object
        #
        # @param (see #bucket_copy_object)
        #
        # @option (see #bucket_copy_object)
        #
        # @raise [RequestError]
        #
        # @return [true]
        #
        # @see Client#bucket_copy_object
        def copy(*args)
          !!client.bucket_copy_object(*args)
        end

        # Get Object
        #
        # @param (see #bucket_get_object)
        #
        # @option (see #bucket_get_object)
        #
        # @raise [RequestError]
        #
        # @return [String]
        #
        # @see Client#bucekt_get_object
        def get(*args)
          client.bucket_get_object(*args).body
        end

        # Append data to a object, will create Appendable object
        #
        # @see https://docs.aliyun.com/#/pub/oss/api-reference/object&AppendObject Append Object
        #
        # @param (see #bucket_append_object)
        #
        # @raise (see #bucket_append_object)
        #
        # @return [true]
        #
        # @see Client#bucket_append_object
        def append(*args)
          !!client.bucket_append_object(*args)
        end

      end
    end
  end
end
